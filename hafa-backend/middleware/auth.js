import jwt from 'jsonwebtoken';

export const TOKEN_TTL = '30d';

export const jwtSecret = () => {
  const s = process.env.JWT_SECRET;
  if (!s || s.length < 16) throw new Error('JWT_SECRET is missing or too short (min 16 characters)');
  return s;
};

export const signToken = (user) =>
  jwt.sign({ sub: String(user._id), role: user.role }, jwtSecret(), { expiresIn: TOKEN_TTL });

// Header: Authorization: Bearer <token>  ->  req.auth = { sub, role }
export const requireAuth = (req, res, next) => {
  const [scheme, token] = String(req.headers.authorization || '').split(' ');
  if (scheme !== 'Bearer' || !token) return res.status(401).json({ error: 'Login required' });
  try {
    req.auth = jwt.verify(token, jwtSecret());
    return next();
  } catch {
    return res.status(401).json({ error: 'Session expired, please log in again' });
  }
};
