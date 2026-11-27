import mongoose from 'mongoose';

export const SELF_SERVICE_ROLES = ['consumer', 'artisan'];
export const ROLES = [...SELF_SERVICE_ROLES, 'administrator'];

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    passwordHash: { type: String, required: true },
    role: { type: String, enum: ROLES, default: 'consumer' },
  },
  { timestamps: true }
);

// Jangan sesekali hantar hash kata laluan ke klien
userSchema.set('toJSON', {
  transform: (_doc, ret) => ({
    id: String(ret._id),
    name: ret.name,
    email: ret.email,
    role: ret.role,
    joinedDate: ret.createdAt ? new Date(ret.createdAt).toISOString().slice(0, 10) : '',
  }),
});

export default mongoose.model('User', userSchema);
