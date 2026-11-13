import 'dotenv/config';
import mongoose from 'mongoose';
import Product from '../models/Product.js';
import { heritageProducts } from './mockData.js';

await mongoose.connect(process.env.MONGO_URI);
await Product.deleteMany({});
await Product.insertMany(heritageProducts);
console.log(`Seeded ${heritageProducts.length} products`);
await mongoose.disconnect();
