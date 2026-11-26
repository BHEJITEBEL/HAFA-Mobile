import { Router } from 'express';
import bcrypt from 'bcryptjs';
import User, { SELF_SIGNUP_ROLES } from '../models/User.js';
import { requireAuth, signToken } from '../middleware/auth.js';

const router = Router();

const str = (v, max) => (typeof v === 'string' ? v.trim().slice(0, max) : '');
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MIN_PASSWORD = 8;
const MAX_PASSWORD = 72; // bcrypt hanya membaca 72 bait pertama

// Hash palsu: digunakan apabila emel tidak wujud supaya masa tindak balas
// sama, jadi penyerang tidak dapat meneka emel mana yang berdaftar.
const DUMMY_HASH = bcrypt.hashSync('dummy-password-for-timing', 12);

const passwordProblem = (pw) => {
  if (typeof pw !== 'string' || pw.length < MIN_PASSWORD) {
    return `Password must be at least ${MIN_PASSWORD} characters`;
  }
  if (Buffer.byteLength(pw, 'utf8') > MAX_PASSWORD) {
    return `Password must be at most ${MAX_PASSWORD} characters`;
  }
  return null;
};

// POST /api/auth/register  { name, email, password, role? }
router.post('/register', async (req, res, next) => {
  try {
    const name = str(req.body?.name, 100);
    const email = str(req.body?.email, 254).toLowerCase();
    const password = req.body?.password;
    const role = str(req.body?.role, 20) || 'consumer';

    if (!name) return res.status(400).json({ error: 'Name is required' });
    if (!EMAIL_RE.test(email)) return res.status(400).json({ error: 'Please enter a valid email address' });
    const pwErr = passwordProblem(password);
    if (pwErr) return res.status(400).json({ error: pwErr });
    // Administrator TIDAK boleh didaftar sendiri — cipta melalui skrip seed.
    if (!SELF_SIGNUP_ROLES.includes(role)) {
      return res.status(400).json({ error: 'Invalid role' });
    }

    if (await User.exists({ email })) {
      return res.status(409).json({ error: 'This email is already registered' });
    }

    const user = new User({ name, email, role });
    await user.setPassword(password);
    try {
      await user.save();
    } catch (err) {
      // Dua pendaftaran serentak dengan emel yang sama -> indeks unik menolak
      if (err?.code === 11000) {
        return res.status(409).json({ error: 'This email is already registered' });
      }
      throw err;
    }

    res.status(201).json({ token: signToken(user), user });
  } catch (err) {
    next(err);
  }
});

// POST /api/auth/login  { email, password }
router.post('/login', async (req, res, next) => {
  try {
    const email = str(req.body?.email, 254).toLowerCase();
    const password = typeof req.body?.password === 'string' ? req.body.password : '';
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = await User.findOne({ email }).select('+passwordHash');
    const ok = user
      ? await user.checkPassword(password)
      : (await bcrypt.compare(password, DUMMY_HASH), false);

    // Mesej yang sama untuk emel salah ATAU kata laluan salah
    if (!ok) return res.status(401).json({ error: 'Incorrect email or password' });

    res.json({ token: signToken(user), user });
  } catch (err) {
    next(err);
  }
});

// GET /api/auth/me  (Authorization: Bearer <token>)
router.get('/me', requireAuth, (req, res) => {
  res.json({ user: req.user });
});

export default router;
