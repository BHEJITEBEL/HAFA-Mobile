import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';
import User from '../models/User.js';

const secret = () => {
  const s = process.env.JWT_SECRET;
  if (!s) throw new Error('JWT_SECRET is not set');
  return s;
};

/** Cipta token log masuk untuk pengguna. */
export const signToken = (user) =>
  jwt.sign({ sub: String(user._id), role: user.role }, secret(), {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    algorithm: 'HS256',
  });

/**
 * Wajibkan log masuk. Baca "Authorization: Bearer <token>", sahkan token,
 * kemudian muat pengguna dari DB (supaya akaun yang dipadam / peranan yang
 * ditukar berkuat kuasa serta-merta). Hasil: req.user.
 */
export const requireAuth = async (req, res, next) => {
  try {
    const [scheme, token] = String(req.headers.authorization || '').split(' ');
    if (scheme !== 'Bearer' || !token) {
      return res.status(401).json({ error: 'Login required' });
    }

    let payload;
    try {
      payload = jwt.verify(token, secret(), { algorithms: ['HS256'] });
    } catch {
      return res.status(401).json({ error: 'Session expired or invalid. Please log in again.' });
    }

    if (!mongoose.isValidObjectId(payload.sub)) {
      return res.status(401).json({ error: 'Session expired or invalid. Please log in again.' });
    }
    const user = await User.findById(payload.sub);
    if (!user) {
      return res.status(401).json({ error: 'Account no longer exists' });
    }

    req.user = user;
    next();
  } catch (err) {
    next(err);
  }
};

/** Hadkan laluan kepada peranan tertentu. Guna SELEPAS requireAuth. */
export const requireRole =
  (...roles) =>
  (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'You do not have permission to do this' });
    }
    next();
  };
