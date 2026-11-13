import mongoose from 'mongoose';

const { Mixed } = mongoose.Schema.Types;

const productSchema = new mongoose.Schema(
  {
    id: { type: String, unique: true, index: true }, // e.g. "HP001"
    name: { type: String, required: true },
    category: { type: String, index: true },
    description: String,
    culturalSignificance: String,
    artisan: Mixed,
    materials: [String],
    productionDate: String,
    productionMethod: String,
    price: String,
    images: [String],
    verificationId: { type: String, unique: true, sparse: true },
    blockchainHash: String,
    ipfsCid: String,
    heritagePassportNumber: String,
    status: { type: String, default: 'Pending Verification', index: true },
    ownershipHistory: [Mixed],
    provenanceTimeline: [Mixed],
    qrCode: String,
    touristScans: { type: Number, default: 0 },
    verificationRequests: { type: Number, default: 0 },
  },
  { timestamps: true }
);

// Hide Mongo internals from API responses
productSchema.set('toJSON', {
  transform: (_doc, ret) => {
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

export default mongoose.model('Product', productSchema);
