import { Router } from 'express';
import bcrypt from 'bcryptjs';
import User, { SELF_SERVICE_ROLES } from '../models/User.js';
import { requireAuth, signToken } from '../middleware/auth.js';

const router = Router();

const str = (v, max = 200) => (typeof v === 'string' ? v.trim().slice(0, max) : '');
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Had cubaan log masuk ringkas (dalam memori): 10 cubaan gagal / 15 minit bagi setiap IP + emel
const WINDOW_MS = 15 * 60 * 1000;
const MAX_FAILS = 10;
const fails = new Map();
const failKey = (req, email) => `${req.ip}|${email}`;
const isLocked = (key) => {
  const f = fails.get(key);
  if (!f) return false;
  if (Date.now() - f.first > WINDOW_MS) {
    fails.delete(key);
    return false;
  }
  return f.count >= MAX_FAILS;
};
const recordFail = (key) => {
  const f = fails.get(key);
  if (!f || Date.now() - f.first > WINDOW_MS) fails.set(key, { first: Date.now(), count: 1 });
  else f.count += 1;
};

// POST /api/auth/register  { name, email, password, role }
router.post('/register', async (req, res, next) => {
  try {
    const name = str(req.body?.name);
    const email = str(req.body?.email).toLowerCase();
    const password = typeof req.body?.password === 'string' ? req.body.password : '';
    const role = SELF_SERVICE_ROLES.includes(req.body?.role) ? req.body.role : 'consumer';

    if (!name) return res.status(400).json({ error: 'Name is required' });
    if (!EMAIL_RE.test(email)) return res.status(400).json({ error: 'Enter a valid email' });
    if (password.length < 6) return res.status(400).json({ error: 'Password must be at least 6 characters' });
    if (password.length > 72) return res.status(400).json({ error: 'Password is too long (max 72 characters)' });

    if (await User.exists({ email })) {
      return res.status(409).json({ error: 'An account with this email already exists' });
    }
    const user = await User.create({ name, email, role, passwordHash: await bcrypt.hash(password, 10) });
    res.status(201).json({ token: signToken(user), user });
  } catch (err) {
    if (err?.code === 11000) return res.status(409).json({ error: 'An account with this email already exists' });
    next(err);
  }
});

// POST /api/auth/login  { email, password }
router.post('/login', async (req, res, next) => {
  try {
    const email = str(req.body?.email).toLowerCase();
    const password = typeof req.body?.password === 'string' ? req.body.password : '';
    if (!email || !password) return res.status(400).json({ error: 'Email and password are required' });

    const key = failKey(req, email);
    if (isLocked(key)) {
      return res.status(429).json({ error: 'Too many failed attempts. Try again in 15 minutes.' });
    }
    const user = await User.findOne({ email });
    const ok = user ? await bcrypt.compare(password, user.passwordHash) : false;
    if (!ok) {
      recordFail(key);
      return res.status(401).json({ error: 'Incorrect email or password' });
    }
    fails.delete(key);
    res.json({ token: signToken(user), user });
  } catch (err) {
    next(err);
  }
});

// GET /api/auth/me  (Authorization: Bearer <token>)
router.get('/me', requireAuth, async (req, res, next) => {
  try {
    const user = await User.findById(req.auth.sub);
    if (!user) return res.status(401).json({ error: 'Account no longer exists' });
    res.json({ user });
  } catch (err) {
    next(err);
  }
});

export default router;
