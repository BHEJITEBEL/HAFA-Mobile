import 'dotenv/config';
import mongoose from 'mongoose';
import app from './app.js';
import { jwtSecret } from './middleware/auth.js';
import Product from './models/Product.js';
import { heritageProducts } from './seed/mockData.js';

const PORT = process.env.PORT || 8001;

try {
  jwtSecret(); // gagal awal jika JWT_SECRET tiada
  await mongoose.connect(process.env.MONGO_URI);
  console.log('MongoDB connected');

  // Isi data contoh secara automatik pada kali pertama (koleksi kosong)
  if (process.env.AUTO_SEED !== 'false' && (await Product.estimatedDocumentCount()) === 0) {
    await Product.insertMany(heritageProducts);
    console.log(`Seeded ${heritageProducts.length} sample products`);
  }

  app.listen(PORT, '0.0.0.0', () => console.log(`HAFA API running on port ${PORT}`));
} catch (err) {
  console.error('Failed to start:', err.message);
  process.exit(1);
}
