const Proposal = require('../models/Proposal');
const User = require('../models/User');
const { createNotification } = require('./notification.service');
const { PROPOSAL_STATUSES, NOTIFICATION_TYPES, ROLES } = require('../utils/constants');

const daysSince = (date) => {
  const now = new Date();
  const diff = now - new Date(date);
  return Math.floor(diff / (1000 * 60 * 60 * 24));
};

/**
 * Main reminder scanning logic.
 * Called by the cron job.
 */
const runReminderScans = async () => {
  console.log('[Reminders] Running reminder scan...');

  try {
    const [directors, financeDirectors] = await Promise.all([
      User.find({ role: ROLES.DIRECTOR, isActive: true, isDeleted: false }),
      User.find({ role: ROLES.FINANCE_DIRECTOR, isActive: true, isDeleted: false }),
    ]);

    const financeDirectorIds = financeDirectors.map((u) => u._id);

    // 1. Bills Pending (Approved → Waiting for Bills, no bills for X days)
    const billsPendingProposals = await Proposal.find({
      status: PROPOSAL_STATUSES.WAITING_FOR_BILLS,
      isDeleted: false,
      'bills.0': { $exists: false }, // no bills uploaded yet
    }).populate('createdBy', 'name _id');

    for (const proposal of billsPendingProposals) {
      const days = daysSince(proposal.approvedAt || proposal.updatedAt);
      const threshold = parseInt(process.env.BILLS_PENDING_DAYS) || 3;
      if (days >= threshold) {
        // Notify director
        await createNotification({
          userId: proposal.createdBy._id,
          type: NOTIFICATION_TYPES.REMINDER_BILLS_PENDING,
          title: '⏰ Bills Upload Reminder',
          message: `Your proposal "${proposal.title}" has been approved for ${days} days. Please upload your bills.`,
          relatedProposalId: proposal._id,
        });
      }
    }

    // 2. No action within X days (Submitted / Under Review)
    const noActionProposals = await Proposal.find({
      status: { $in: [PROPOSAL_STATUSES.SUBMITTED, PROPOSAL_STATUSES.UNDER_REVIEW] },
      isDeleted: false,
    });

    for (const proposal of noActionProposals) {
      const days = daysSince(proposal.submittedAt || proposal.updatedAt);
      const threshold = parseInt(process.env.NO_ACTION_DAYS) || 5;
      if (days >= threshold) {
        for (const fdId of financeDirectorIds) {
          await createNotification({
            userId: fdId,
            type: NOTIFICATION_TYPES.REMINDER_NO_ACTION,
            title: '⏰ Proposal Awaiting Review',
            message: `Proposal "${proposal.title}" has been waiting for review for ${days} days.`,
            relatedProposalId: proposal._id,
          });
        }
      }
    }

    // 3. Resubmission Pending (Rejected, not yet resubmitted for X days)
    const resubmitPendingProposals = await Proposal.find({
      status: PROPOSAL_STATUSES.REJECTED,
      isDeleted: false,
    }).populate('createdBy', '_id name');

    for (const proposal of resubmitPendingProposals) {
      const days = daysSince(proposal.reviewedAt || proposal.updatedAt);
      const threshold = parseInt(process.env.RESUBMISSION_PENDING_DAYS) || 3;
      if (days >= threshold) {
        await createNotification({
          userId: proposal.createdBy._id,
          type: NOTIFICATION_TYPES.REMINDER_RESUBMISSION,
          title: '⏰ Resubmission Reminder',
          message: `Your proposal "${proposal.title}" was rejected ${days} days ago. Please review and resubmit.`,
          relatedProposalId: proposal._id,
        });
      }
    }

    // 4. Expense Verification Pending (bills uploaded but not verified)
    const verificationPendingProposals = await Proposal.find({
      status: PROPOSAL_STATUSES.WAITING_FOR_BILLS,
      isDeleted: false,
      'bills.verificationStatus': 'Pending',
    });

    for (const proposal of verificationPendingProposals) {
      const lastBill = proposal.bills[proposal.bills.length - 1];
      if (!lastBill) continue;
      const days = daysSince(lastBill.uploadedAt);
      const threshold = parseInt(process.env.VERIFICATION_PENDING_DAYS) || 3;
      if (days >= threshold) {
        for (const fdId of financeDirectorIds) {
          await createNotification({
            userId: fdId,
            type: NOTIFICATION_TYPES.REMINDER_VERIFICATION,
            title: '⏰ Bill Verification Pending',
            message: `Proposal "${proposal.title}" has bills uploaded ${days} days ago awaiting verification.`,
            relatedProposalId: proposal._id,
          });
        }
      }
    }

    console.log('[Reminders] Scan complete.');
  } catch (error) {
    console.error('[Reminders] Error during scan:', error.message);
  }
};

module.exports = { runReminderScans };
