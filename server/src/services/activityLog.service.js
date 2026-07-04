const ActivityLog = require('../models/ActivityLog');

/**
 * Write an immutable activity log entry.
 * @param {object} options
 * @param {string|null} options.proposalId
 * @param {object} options.actor - req.user
 * @param {string} options.action - from ACTIVITY_ACTIONS constants
 * @param {object} [options.metadata]
 */
const logActivity = async ({ proposalId = null, actor, action, metadata = {} }) => {
  try {
    await ActivityLog.create({
      proposalId,
      actorId: actor._id,
      actorRole: actor.role,
      action,
      metadata,
      timestamp: new Date(),
    });
  } catch (error) {
    // Log service must never throw — just console.error
    console.error('[ActivityLog] Failed to write log:', error.message);
  }
};

module.exports = { logActivity };
