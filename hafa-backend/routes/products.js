import { Router } from 'express';
import crypto from 'node:crypto';
import Product from '../models/Product.js';

const router = Router();

const escapeRegex = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const str = (v, max = 2000) => (typeof v === 'string' ? v.trim().slice(0, max) : '');
const keyFilter = (key) => ({ $or: [{ id: key }, { verificationId: key }] });

// GET /api/products?category=Songket&status=Verified&q=batik
router.get('/', async (req, res, next) => {
  try {
    const { category, status, q } = req.query;
    const filter = {};
    if (typeof category === 'string') filter.category = category;
    if (typeof status === 'string') filter.status = status;
    if (typeof q === 'string' && q.trim()) {
      filter.name = { $regex: escapeRegex(q.trim()), $options: 'i' };
    }
    const products = await Product.find(filter).sort({ id: 1 });
    res.json(products);
  } catch (err) {
    next(err);
  }
});

// GET /api/products/:id  (terima "HP001" atau verificationId)
router.get('/:id', async (req, res, next) => {
  try {
    const product = await Product.findOne(keyFilter(String(req.params.id)));
    if (!product) return res.status(404).json({ error: 'Product not found' });
    res.json(product);
  } catch (err) {
    next(err);
  }
});

// POST /api/products/:id/scan  { method: "qr" | "nfc" | "manual" }
// Merekod bilangan imbasan / permintaan pengesahan untuk statistik artisan
router.post('/:id/scan', async (req, res, next) => {
  try {
    const method = str(req.body?.method, 10);
    const inc = { verificationRequests: 1 };
    if (method === 'qr' || method === 'nfc') inc.touristScans = 1;
    const product = await Product.findOneAndUpdate(
      keyFilter(String(req.params.id)),
      { $inc: inc },
      { new: true }
    );
    if (!product) return res.status(404).json({ error: 'Product not found' });
    res.json({ ok: true, touristScans: product.touristScans, verificationRequests: product.verificationRequests });
  } catch (err) {
    next(err);
  }
});

const kualaLumpurTime = () => {
  try {
    return new Date().toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      timeZone: 'Asia/Kuala_Lumpur',
    });
  } catch {
    return new Date().toISOString().slice(11, 16);
  }
};

const nextNumber = async () => {
  const rows = await Product.find({}, 'id').lean();
  const nums = rows.map((r) => Number(String(r.id).replace(/\D/g, ''))).filter(Number.isFinite);
  return Math.max(0, ...nums) + 1;
};

// POST /api/products  -> daftar produk baharu (status: Pending Verification)
// Nota: blockchainHash & ipfsCid dijana secara SIMULASI (sama seperti data contoh projek ini).
router.post('/', async (req, res, next) => {
  try {
    const b = req.body ?? {};
    const a = b.artisan ?? {};
    const name = str(b.name, 200);
    const artisanName = str(a.name, 200);
    if (!name) return res.status(400).json({ error: 'name is required' });
    if (!artisanName) return res.status(400).json({ error: 'artisan.name is required' });

    const images = (Array.isArray(b.images) ? b.images : [])
      .filter((u) => typeof u === 'string' && (u.startsWith('/uploads/') || /^https?:\/\//.test(u)))
      .slice(0, 6);
    const materials = (Array.isArray(b.materials) ? b.materials : [])
      .map((m) => str(m, 100))
      .filter(Boolean)
      .slice(0, 20);

    const today = new Date().toISOString().slice(0, 10);
    const year = new Date().getFullYear();
    const time = kualaLumpurTime();

    for (let attempt = 0; attempt < 3; attempt += 1) {
      const num = String((await nextNumber()) + attempt).padStart(3, '0');
      try {
        const product = await Product.create({
          id: `HP${num}`,
          name,
          category: str(b.category, 100),
          description: str(b.description),
          culturalSignificance: str(b.culturalSignificance),
          artisan: {
            name: artisanName,
            location: str(a.location, 200),
            experience: str(a.experience, 100),
            verified: false,
            bio: str(a.bio),
          },
          materials,
          productionDate: str(b.productionDate, 20) || today,
          productionMethod: str(b.productionMethod),
          price: str(b.price, 50),
          images,
          verificationId: `HAFA-${year}-NEW-${num}`,
          blockchainHash: `0x${crypto.randomBytes(32).toString('hex')}`,
          ipfsCid: `Qm${crypto.randomBytes(33).toString('base64url').slice(0, 44)}`,
          heritagePassportNumber: `MY-HRTG-${year}-NEW-${num}`,
          status: 'Pending Verification',
          ownershipHistory: [
            { owner: artisanName, date: today, type: 'Created', verificationBadge: false },
          ],
          provenanceTimeline: [
            { event: 'Product Registered', date: today, timestamp: time, responsible: artisanName, verified: true },
          ],
          touristScans: 0,
          verificationRequests: 0,
        });
        return res.status(201).json(product);
      } catch (err) {
        if (err?.code === 11000 && attempt < 2) continue; // bertembung ID -> cuba nombor seterusnya
        throw err;
      }
    }
    return res.status(409).json({ error: 'Could not allocate a product id, please retry' });
  } catch (err) {
    next(err);
  }
});

export default router;
