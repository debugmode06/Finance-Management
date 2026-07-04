const mongoose = require('mongoose');
const {
  PROPOSAL_STATUSES,
  PROPOSAL_PRIORITIES,
  DEPARTMENTS,
  BILL_VERIFICATION_STATUSES,
} = require('../utils/constants');

const attachmentSchema = new mongoose.Schema(
  {
    url: { type: String, required: true },
    fileName: { type: String, required: true },
    fileType: { type: String, required: true },
    category: {
      type: String,
      enum: ['quotation', 'bill', 'other'],
      default: 'other',
    },
    uploadedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    uploadedAt: { type: Date, default: Date.now },
  },
  { _id: true }
);

const billSchema = new mongoose.Schema(
  {
    url: { type: String, required: true },
    fileName: { type: String, required: true },
    fileType: { type: String, required: true },
    amount: { type: Number, default: 0 },
    uploadedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    uploadedAt: { type: Date, default: Date.now },
    verificationStatus: {
      type: String,
      enum: Object.values(BILL_VERIFICATION_STATUSES),
      default: BILL_VERIFICATION_STATUSES.PENDING,
    },
    verificationNote: { type: String, default: null },
    verifiedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
    verifiedAt: { type: Date, default: null },
  },
  { _id: true }
);

const proposalSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Proposal title is required'],
      trim: true,
      minlength: [5, 'Title must be at least 5 characters'],
      maxlength: [120, 'Title cannot exceed 120 characters'],
    },
    department: {
      type: String,
      enum: Object.values(DEPARTMENTS),
      required: [true, 'Department is required'],
    },
    eventName: {
      type: String,
      required: [true, 'Event name is required'],
      trim: true,
    },
    purpose: {
      type: String,
      required: [true, 'Purpose is required'],
      trim: true,
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      minlength: [20, 'Description must be at least 20 characters'],
    },
    requestedBudget: {
      type: Number,
      required: [true, 'Requested budget is required'],
      min: [1, 'Budget must be greater than 0'],
    },
    approvedBudget: {
      type: Number,
      default: null,
    },
    actualExpense: {
      type: Number,
      default: 0,
    },
    priority: {
      type: String,
      enum: Object.values(PROPOSAL_PRIORITIES),
      required: [true, 'Priority is required'],
    },
    requiredDate: {
      type: Date,
      required: [true, 'Required date is required'],
    },
    notes: {
      type: String,
      default: null,
    },
    attachments: [attachmentSchema],
    bills: [billSchema],
    status: {
      type: String,
      enum: Object.values(PROPOSAL_STATUSES),
      default: PROPOSAL_STATUSES.DRAFT,
    },
    rejectionReason: {
      type: String,
      default: null,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    reviewedAt: {
      type: Date,
      default: null,
    },
    submittedAt: {
      type: Date,
      default: null,
    },
    approvedAt: {
      type: Date,
      default: null,
    },
    completedAt: {
      type: Date,
      default: null,
    },
    isDeleted: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
proposalSchema.index({ status: 1 });
proposalSchema.index({ department: 1 });
proposalSchema.index({ createdBy: 1 });
proposalSchema.index({ isDeleted: 1 });
proposalSchema.index({ requiredDate: 1 });
proposalSchema.index({ createdAt: -1 });

// Virtual: remaining budget
proposalSchema.virtual('remainingBudget').get(function () {
  if (this.approvedBudget == null) return null;
  return this.approvedBudget - this.actualExpense;
});

proposalSchema.set('toJSON', { virtuals: true });
proposalSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Proposal', proposalSchema);
