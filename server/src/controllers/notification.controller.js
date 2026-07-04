const Notification = require('../models/Notification');
const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/apiResponse');

// GET /api/v1/notifications
const getNotifications = asyncHandler(async (req, res) => {
  const { page = 1, limit = 30, unreadOnly } = req.query;

  const query = { userId: req.user._id };
  if (unreadOnly === 'true') query.isRead = false;

  const skip = (parseInt(page) - 1) * parseInt(limit);

  const [notifications, total, unreadCount] = await Promise.all([
    Notification.find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit))
      .populate('relatedProposalId', 'title status'),
    Notification.countDocuments(query),
    Notification.countDocuments({ userId: req.user._id, isRead: false }),
  ]);

  return ApiResponse.success(res, 'Notifications retrieved', notifications, {
    total,
    unreadCount,
    page: parseInt(page),
    limit: parseInt(limit),
    totalPages: Math.ceil(total / parseInt(limit)),
  });
});

// PATCH /api/v1/notifications/:id/read
const markRead = asyncHandler(async (req, res) => {
  const notification = await Notification.findOneAndUpdate(
    { _id: req.params.id, userId: req.user._id },
    { isRead: true },
    { new: true }
  );

  if (!notification) return ApiResponse.notFound(res, 'Notification not found');

  return ApiResponse.success(res, 'Notification marked as read', notification);
});

// PATCH /api/v1/notifications/read-all
const markAllRead = asyncHandler(async (req, res) => {
  const result = await Notification.updateMany(
    { userId: req.user._id, isRead: false },
    { isRead: true }
  );

  return ApiResponse.success(res, `Marked ${result.modifiedCount} notifications as read`);
});

module.exports = { getNotifications, markRead, markAllRead };
