import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

export const ROLES = ['consumer', 'artisan', 'administrator'];
// Peranan yang boleh dipilih sendiri semasa mendaftar (BUKAN administrator)
export const SELF_SIGNUP_ROLES = ['consumer', 'artisan'];

const BCRYPT_ROUNDS = 12;

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true, maxlength: 100 },
    email: {
      type: String,
      required: true,
      unique: true, // indeks unik: satu akaun bagi setiap emel
      lowercase: true,
      trim: true,
      maxlength: 254,
      match: [/^[^\s@]+@[^\s@]+\.[^\s@]+$/, 'Invalid email address'],
    },
    // Hanya hash bcrypt disimpan. select:false -> tidak dibaca dari DB kecuali diminta.
    passwordHash: { type: String, required: true, select: false },
    role: { type: String, enum: ROLES, default: 'consumer', index: true },
  },
  { timestamps: true } // createdAt = tarikh menyertai, updatedAt
);

/** Tetapkan kata laluan baharu (di-hash, kata laluan asal tidak disimpan). */
userSchema.methods.setPassword = async function setPassword(plain) {
  this.passwordHash = await bcrypt.hash(plain, BCRYPT_ROUNDS);
};

/** Semak kata laluan. Dokumen mesti dimuat dengan .select('+passwordHash'). */
userSchema.methods.checkPassword = function checkPassword(plain) {
  if (!this.passwordHash) return Promise.resolve(false);
  return bcrypt.compare(plain, this.passwordHash);
};

// Bentuk yang dihantar ke aplikasi: tiada hash, tiada medan dalaman Mongo
userSchema.set('toJSON', {
  transform: (_doc, ret) => {
    ret.id = String(ret._id);
    ret.joinedDate = ret.createdAt;
    delete ret._id;
    delete ret.__v;
    delete ret.passwordHash;
    return ret;
  },
});

export default mongoose.model('User', userSchema);
