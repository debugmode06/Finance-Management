const mongoose = require('mongoose');
const { PROPOSAL_STATUSES } = require('../utils/constants');

const proposalHistorySchema = new mongoose.Schema(
  {
    proposalId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Proposal',
      required: true,
    },
    status: {
      type: String,
      enum: Object.values(PROPOSAL_STATUSES),
      required: true,
    },
    changedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    note: {
      type: String,
      default: null,
    },
    timestamp: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: false,
  }
);

proposalHistorySchema.index({ proposalId: 1, timestamp: -1 });

module.exports = mongoose.model('ProposalHistory', proposalHistorySchema);
