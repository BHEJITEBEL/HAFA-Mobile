import express, { Router } from 'express';
import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const UPLOAD_DIR = process.env.UPLOAD_DIR || path.join(__dirname, '..', 'uploads');

const router = Router();

const EXT = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp' };
const TYPES = Object.keys(EXT);

// Semak "magic bytes" supaya fail palsu (bukan gambar) ditolak
const looksLikeImage = (buf, type) => {
  if (type === 'image/jpeg') return buf[0] === 0xff && buf[1] === 0xd8 && buf[2] === 0xff;
  if (type === 'image/png') return buf.subarray(0, 4).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47]));
  if (type === 'image/webp') {
    return buf.subarray(0, 4).toString('ascii') === 'RIFF' && buf.subarray(8, 12).toString('ascii') === 'WEBP';
  }
  return false;
};

// POST /api/uploads  (badan = bait imej mentah, Content-Type = image/jpeg|png|webp)
router.post('/', express.raw({ type: TYPES, limit: '8mb' }), async (req, res, next) => {
  try {
    const type = req.is(TYPES);
    if (!type || !Buffer.isBuffer(req.body) || req.body.length === 0) {
      return res
        .status(400)
        .json({ error: 'Send raw image bytes with Content-Type image/jpeg, image/png or image/webp' });
    }
    if (!looksLikeImage(req.body, type)) {
      return res.status(400).json({ error: 'File content does not match its image type' });
    }
    await fs.mkdir(UPLOAD_DIR, { recursive: true });
    const name = `${Date.now()}-${crypto.randomBytes(6).toString('hex')}.${EXT[type]}`;
    await fs.writeFile(path.join(UPLOAD_DIR, name), req.body);
    res.status(201).json({ path: `/uploads/${name}` });
  } catch (err) {
    next(err);
  }
});

export default router;
