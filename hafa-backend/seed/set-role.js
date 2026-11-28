// Tukar peranan akaun sedia ada (cth. jadikan admin). Pendaftaran awam hanya benarkan consumer/artisan.
//
// Docker :  docker compose exec api node seed/set-role.js <email> administrator
// Tempatan:  node seed/set-role.js <email> administrator
import 'dotenv/config';
import mongoose from 'mongoose';
import User, { ROLES } from '../models/User.js';

const [email, role = 'administrator'] = process.argv.slice(2);
if (!email || !ROLES.includes(role)) {
  console.error(`Usage: node seed/set-role.js <email> [${ROLES.join('|')}]`);
  process.exit(1);
}

await mongoose.connect(process.env.MONGO_URI);
const user = await User.findOneAndUpdate({ email: email.trim().toLowerCase() }, { role }, { new: true });
console.log(user ? `${user.email} is now ${user.role}` : `No account found for ${email}`);
await mongoose.disconnect();
process.exit(user ? 0 : 1);
