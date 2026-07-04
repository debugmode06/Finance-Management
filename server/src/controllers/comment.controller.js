const Comment = require('../models/Comment');
const Proposal = require('../models/Proposal');
const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/apiResponse');
const { logActivity } = require('../services/activityLog.service');
const { createNotification } = require('../services/notification.service');
const { ACTIVITY_ACTIONS, NOTIFICATION_TYPES, ROLES } = require('../utils/constants');

// POST /api/v1/proposals/:id/comments
const addComment = asyncHandler(async (req, res) => {
  const { message } = req.body;

  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  // Director can only comment on their own proposal
  if (
    req.user.role === ROLES.DIRECTOR &&
    proposal.createdBy.toString() !== req.user._id.toString()
  ) {
    return ApiResponse.forbidden(res);
  }

  const comment = await Comment.create({
    proposalId: req.params.id,
    authorId: req.user._id,
    authorRole: req.user.role,
    message,
  });

  await comment.populate('authorId', 'name email role profileImage');

  await logActivity({
    proposalId: req.params.id,
    actor: req.user,
    action: ACTIVITY_ACTIONS.COMMENT_ADDED,
    metadata: { commentId: comment._id },
  });

  // Notify the other party
  let notifyUserId;
  if (req.user.role === ROLES.DIRECTOR) {
    // Notify finance director
    const { User } = require('../models/User') || {};
    const UserModel = require('../models/User');
    const fd = await UserModel.findOne({ role: ROLES.FINANCE_DIRECTOR, isActive: true, isDeleted: false });
    if (fd) notifyUserId = fd._id;
  } else {
    // Finance director is commenting — notify proposal owner (director)
    notifyUserId = proposal.createdBy;
  }

  if (notifyUserId) {
    await createNotification({
      userId: notifyUserId,
      type: NOTIFICATION_TYPES.NEW_COMMENT,
      title: 'New Comment',
      message: `${req.user.name} commented on "${proposal.title}": ${message.substring(0, 80)}${message.length > 80 ? '...' : ''}`,
      relatedProposalId: proposal._id,
    });
  }

  return ApiResponse.created(res, 'Comment added', comment);
});

// GET /api/v1/proposals/:id/comments
const getComments = asyncHandler(async (req, res) => {
  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  if (
    req.user.role === ROLES.DIRECTOR &&
    proposal.createdBy.toString() !== req.user._id.toString()
  ) {
    return ApiResponse.forbidden(res);
  }

  const comments = await Comment.find({ proposalId: req.params.id })
    .populate('authorId', 'name email role profileImage')
    .sort({ createdAt: 1 });

  return ApiResponse.success(res, 'Comments retrieved', comments);
});

module.exports = { addComment, getComments };
