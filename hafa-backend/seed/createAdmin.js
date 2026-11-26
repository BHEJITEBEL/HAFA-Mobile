// Cipta (atau naik taraf) akaun administrator.
// Administrator tidak boleh didaftar melalui aplikasi, jadi guna skrip ini.
//
// Dengan Docker (disyorkan):
//   docker compose exec api npm run create-admin
// Tanpa Docker:
//   npm run create-admin
//
// Tanpa soalan (cth. untuk automasi), tetapkan pemboleh ubah persekitaran:
//   ADMIN_NAME, ADMIN_EMAIL, ADMIN_PASSWORD
import 'dotenv/config';
import readline from 'node:readline/promises';
import { stdin, stdout } from 'node:process';
import mongoose from 'mongoose';
import User from '../models/User.js';

const MIN_PASSWORD = 8;

const rl = readline.createInterface({ input: stdin, output: stdout });
const ask = async (envName, question) => process.env[envName] || (await rl.question(question)).trim();

try {
  const email = (await ask('ADMIN_EMAIL', 'Admin email: ')).toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new Error('Invalid email address');

  await mongoose.connect(process.env.MONGO_URI);
  const existing = await User.findOne({ email });

  const name = existing?.name || (await ask('ADMIN_NAME', 'Admin name: ')) || 'Administrator';
  const password = await ask(
    'ADMIN_PASSWORD',
    existing ? 'New password (leave empty to keep the current one): ' : 'Password (min 8 characters): '
  );
  if (!(existing && !password) && password.length < MIN_PASSWORD) {
    throw new Error(`Password must be at least ${MIN_PASSWORD} characters`);
  }

  const user = existing || new User({ name, email });
  user.role = 'administrator';
  if (password) await user.setPassword(password);
  await user.save();

  console.log(`${existing ? 'Updated' : 'Created'} administrator: ${user.email}`);
} catch (err) {
  console.error('Failed:', err.message);
  process.exitCode = 1;
} finally {
  rl.close();
  await mongoose.disconnect();
}
