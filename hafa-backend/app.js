import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import productRoutes from './routes/products.js';
import uploadRoutes, { UPLOAD_DIR } from './routes/uploads.js';

const app = express();

// Gambar di /uploads mesti boleh dimuatkan oleh klien lain (web/mobile)
app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));

// CORS hanya relevan untuk pelayar web. Aplikasi mobile tidak menghantar header Origin.
const origins = (process.env.CLIENT_URL || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);
app.use(cors(origins.length ? { origin: origins } : undefined));

app.use(express.json({ limit: '1mb' }));

app.get('/api/health', (_req, res) => res.json({ ok: true }));
app.use('/uploads', express.static(UPLOAD_DIR, { maxAge: '7d' }));
app.use('/api/uploads', uploadRoutes);
app.use('/api/products', productRoutes);

app.use('/api', (_req, res) => res.status(404).json({ error: 'Not found' }));

// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  if (err?.type === 'entity.too.large') {
    return res.status(413).json({ error: 'Payload too large' });
  }
  if (err?.type === 'entity.parse.failed') {
    return res.status(400).json({ error: 'Invalid JSON body' });
  }
  console.error(err);
  res.status(500).json({ error: 'Server error' });
});

export default app;
