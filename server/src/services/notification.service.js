const Notification = require('../models/Notification');
const { emitToUser } = require('../config/socket');

/**
 * Create a notification for a user and emit it via Socket.IO
 * @param {object} options
 * @param {string} options.userId - recipient user ObjectId
 * @param {string} options.type - from NOTIFICATION_TYPES
 * @param {string} options.title
 * @param {string} options.message
 * @param {string|null} [options.relatedProposalId]
 */
const createNotification = async ({
  userId,
  type,
  title,
  message,
  relatedProposalId = null,
}) => {
  try {
    const notification = await Notification.create({
      userId,
      type,
      title,
      message,
      relatedProposalId,
      isRead: false,
    });

    // Emit real-time via Socket.IO
    emitToUser(userId.toString(), 'notification', {
      _id: notification._id,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      relatedProposalId: notification.relatedProposalId,
      isRead: false,
      createdAt: notification.createdAt,
    });

    return notification;
  } catch (error) {
    console.error('[NotificationService] Failed to create notification:', error.message);
  }
};

/**
 * Notify the finance director when a new proposal is submitted or resubmitted
 */
const notifyFinanceDirector = async ({ type, title, message, proposalId, financeDirectorId }) => {
  if (!financeDirectorId) return;
  return createNotification({
    userId: financeDirectorId,
    type,
    title,
    message,
    relatedProposalId: proposalId,
  });
};

module.exports = { createNotification, notifyFinanceDirector };
