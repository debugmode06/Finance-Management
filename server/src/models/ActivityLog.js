const mongoose = require('mongoose');

const activityLogSchema = new mongoose.Schema(
  {
    proposalId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Proposal',
      default: null,
    },
    actorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    actorRole: {
      type: String,
      required: true,
    },
    action: {
      type: String,
      required: true,
      // e.g. Created, Submitted, Viewed, Rejected, Reason Added, Edited,
      // Resubmitted, Approved, Bills Uploaded, Verified, Completed,
      // Comment Added, Password Changed, Profile Updated, etc.
    },
    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
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

// This collection is immutable — no updates or deletes are ever done
activityLogSchema.index({ proposalId: 1, timestamp: -1 });
activityLogSchema.index({ actorId: 1, timestamp: -1 });

module.exports = mongoose.model('ActivityLog', activityLogSchema);
