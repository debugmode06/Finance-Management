const Proposal = require('../models/Proposal');
const ProposalHistory = require('../models/ProposalHistory');
const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/apiResponse');
const { logActivity } = require('../services/activityLog.service');
const { createNotification } = require('../services/notification.service');
const { buildAttachment, buildBill } = require('../services/storage.service');
const {
  ACTIVITY_ACTIONS,
  PROPOSAL_STATUSES,
  NOTIFICATION_TYPES,
  ROLES,
} = require('../utils/constants');

const addHistory = async (proposalId, status, changedBy, note = null) => {
  await ProposalHistory.create({ proposalId, status, changedBy, note, timestamp: new Date() });
};

const getFinanceDirector = async () => {
  return User.findOne({ role: ROLES.FINANCE_DIRECTOR, isActive: true, isDeleted: false });
};

// POST /api/v1/proposals
const createProposal = asyncHandler(async (req, res) => {
  const { title, eventName, purpose, description, requestedBudget, priority, requiredDate, notes } = req.body;

  const director = await User.findById(req.user._id);

  const proposal = await Proposal.create({
    title,
    department: director.department,
    eventName,
    purpose,
    description,
    requestedBudget: parseFloat(requestedBudget),
    priority,
    requiredDate,
    notes,
    status: PROPOSAL_STATUSES.DRAFT,
    createdBy: req.user._id,
  });

  // Handle quotation attachment
  if (req.file) {
    proposal.attachments.push(buildAttachment(req.file, 'quotation', req.user._id));
    await proposal.save();
  }

  await addHistory(proposal._id, PROPOSAL_STATUSES.DRAFT, req.user._id, 'Proposal created as draft');
  await logActivity({ proposalId: proposal._id, actor: req.user, action: ACTIVITY_ACTIONS.CREATED, metadata: { title } });

  return ApiResponse.created(res, 'Proposal created successfully', proposal);
});

// PUT /api/v1/proposals/:id
const updateProposal = asyncHandler(async (req, res) => {
  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  if (proposal.createdBy.toString() !== req.user._id.toString()) {
    return ApiResponse.forbidden(res, 'You can only edit your own proposals');
  }

  if (![PROPOSAL_STATUSES.DRAFT, PROPOSAL_STATUSES.REJECTED].includes(proposal.status)) {
    return ApiResponse.badRequest(res, 'Proposal can only be edited in Draft or Rejected status');
  }

  const allowed = ['title', 'eventName', 'purpose', 'description', 'requestedBudget', 'priority', 'requiredDate', 'notes'];
  allowed.forEach((field) => {
    if (req.body[field] !== undefined) {
      proposal[field] = field === 'requestedBudget' ? parseFloat(req.body[field]) : req.body[field];
    }
  });

  if (req.file) {
    proposal.attachments.push(buildAttachment(req.file, 'quotation', req.user._id));
  }

  await proposal.save();

  await logActivity({ proposalId: proposal._id, actor: req.user, action: ACTIVITY_ACTIONS.EDITED });

  return ApiResponse.success(res, 'Proposal updated successfully', proposal);
});

// POST /api/v1/proposals/:id/submit
const submitProposal = asyncHandler(async (req, res) => {
  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  if (proposal.createdBy.toString() !== req.user._id.toString()) {
    return ApiResponse.forbidden(res, 'Not your proposal');
  }

  if (![PROPOSAL_STATUSES.DRAFT, PROPOSAL_STATUSES.REJECTED].includes(proposal.status)) {
    return ApiResponse.badRequest(res, 'Only Draft or Rejected proposals can be submitted');
  }

  const newStatus = proposal.status === PROPOSAL_STATUSES.REJECTED
    ? PROPOSAL_STATUSES.RESUBMITTED
    : PROPOSAL_STATUSES.SUBMITTED;

  proposal.status = newStatus;
  proposal.submittedAt = new Date();
  proposal.rejectionReason = null;
  await proposal.save();

  await addHistory(proposal._id, newStatus, req.user._id);

  const action = newStatus === PROPOSAL_STATUSES.RESUBMITTED
    ? ACTIVITY_ACTIONS.RESUBMITTED
    : ACTIVITY_ACTIONS.SUBMITTED;
  await logActivity({ proposalId: proposal._id, actor: req.user, action });

  // Notify finance director
  const fd = await getFinanceDirector();
  if (fd) {
    const isResubmit = newStatus === PROPOSAL_STATUSES.RESUBMITTED;
    await createNotification({
      userId: fd._id,
      type: isResubmit ? NOTIFICATION_TYPES.PROPOSAL_RESUBMITTED : NOTIFICATION_TYPES.PROPOSAL_SUBMITTED,
      title: isResubmit ? 'Proposal Resubmitted' : 'New Proposal Submitted',
      message: `"${proposal.title}" has been ${isResubmit ? 'resubmitted' : 'submitted'} by ${req.user.name}`,
      relatedProposalId: proposal._id,
    });
  }

  return ApiResponse.success(res, `Proposal ${newStatus.toLowerCase()} successfully`, proposal);
});

// GET /api/v1/proposals
const getProposals = asyncHandler(async (req, res) => {
  const {
    status,
    department,
    priority,
    search,
    sortBy = 'createdAt',
    order = 'desc',
    page = 1,
    limit = 20,
    startDate,
    endDate,
  } = req.query;

  const query = { isDeleted: false };

  // Directors only see their own proposals
  if (req.user.role === ROLES.DIRECTOR) {
    query.createdBy = req.user._id;
  }

  if (status) {
    const statuses = status.split(',');
    query.status = statuses.length > 1 ? { $in: statuses } : statuses[0];
  }
  if (department) query.department = department;
  if (priority) query.priority = priority;

  if (search) {
    query.$or = [
      { title: { $regex: search, $options: 'i' } },
      { eventName: { $regex: search, $options: 'i' } },
      { purpose: { $regex: search, $options: 'i' } },
    ];
  }

  if (startDate || endDate) {
    query.createdAt = {};
    if (startDate) query.createdAt.$gte = new Date(startDate);
    if (endDate) query.createdAt.$lte = new Date(endDate);
  }

  const skip = (parseInt(page) - 1) * parseInt(limit);
  const sortOrder = order === 'asc' ? 1 : -1;

  const [proposals, total] = await Promise.all([
    Proposal.find(query)
      .populate('createdBy', 'name email department profileImage')
      .populate('reviewedBy', 'name email')
      .sort({ [sortBy]: sortOrder })
      .skip(skip)
      .limit(parseInt(limit)),
    Proposal.countDocuments(query),
  ]);

  // Dashboard stats
  const stats = await Proposal.aggregate([
    { $match: { isDeleted: false, ...(req.user.role === ROLES.DIRECTOR ? { createdBy: req.user._id } : {}) } },
    { $group: { _id: '$status', count: { $sum: 1 } } },
  ]);

  const statusCounts = {};
  stats.forEach((s) => { statusCounts[s._id] = s.count; });

  return ApiResponse.success(res, 'Proposals retrieved', proposals, {
    total,
    page: parseInt(page),
    limit: parseInt(limit),
    totalPages: Math.ceil(total / parseInt(limit)),
    statusCounts,
  });
});

// GET /api/v1/proposals/:id
const getProposalById = asyncHandler(async (req, res) => {
  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false })
    .populate('createdBy', 'name email department profileImage')
    .populate('reviewedBy', 'name email');

  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  // Directors can only view their own
  if (
    req.user.role === ROLES.DIRECTOR &&
    proposal.createdBy._id.toString() !== req.user._id.toString()
  ) {
    return ApiResponse.forbidden(res);
  }

  await logActivity({ proposalId: proposal._id, actor: req.user, action: ACTIVITY_ACTIONS.VIEWED });

  return ApiResponse.success(res, 'Proposal retrieved', proposal);
});

// DELETE /api/v1/proposals/:id (soft delete, draft only)
const deleteProposal = asyncHandler(async (req, res) => {
  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  if (proposal.createdBy.toString() !== req.user._id.toString()) {
    return ApiResponse.forbidden(res, 'Not your proposal');
  }

  if (proposal.status !== PROPOSAL_STATUSES.DRAFT) {
    return ApiResponse.badRequest(res, 'Only Draft proposals can be deleted');
  }

  proposal.isDeleted = true;
  await proposal.save();

  return ApiResponse.success(res, 'Proposal deleted');
});

// PATCH /api/v1/proposals/:id/approve
const approveProposal = asyncHandler(async (req, res) => {
  const { approvedBudget } = req.body;
  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  if (![PROPOSAL_STATUSES.SUBMITTED, PROPOSAL_STATUSES.UNDER_REVIEW, PROPOSAL_STATUSES.RESUBMITTED].includes(proposal.status)) {
    return ApiResponse.badRequest(res, 'Proposal is not in a reviewable state');
  }

  proposal.status = PROPOSAL_STATUSES.APPROVED;
  proposal.approvedBudget = parseFloat(approvedBudget);
  proposal.reviewedBy = req.user._id;
  proposal.reviewedAt = new Date();
  proposal.approvedAt = new Date();
  proposal.rejectionReason = null;
  await proposal.save();

  await addHistory(proposal._id, PROPOSAL_STATUSES.APPROVED, req.user._id, `Approved with budget RM${approvedBudget}`);
  await logActivity({ proposalId: proposal._id, actor: req.user, action: ACTIVITY_ACTIONS.APPROVED, metadata: { approvedBudget } });

  // Notify director
  await createNotification({
    userId: proposal.createdBy,
    type: NOTIFICATION_TYPES.PROPOSAL_APPROVED,
    title: 'Proposal Approved! 🎉',
    message: `Your proposal "${proposal.title}" has been approved with a budget of RM${approvedBudget}.`,
    relatedProposalId: proposal._id,
  });

  // Auto-move to Waiting for Bills
  proposal.status = PROPOSAL_STATUSES.WAITING_FOR_BILLS;
  await proposal.save();
  await addHistory(proposal._id, PROPOSAL_STATUSES.WAITING_FOR_BILLS, req.user._id, 'Awaiting bill submission');

  await createNotification({
    userId: proposal.createdBy,
    type: NOTIFICATION_TYPES.BILLS_REQUESTED,
    title: 'Please Upload Bills',
    message: `Please upload your bills for "${proposal.title}" to complete the expense claim.`,
    relatedProposalId: proposal._id,
  });

  return ApiResponse.success(res, 'Proposal approved successfully', proposal);
});

// PATCH /api/v1/proposals/:id/reject
const rejectProposal = asyncHandler(async (req, res) => {
  const { reason } = req.body;
  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  if (![PROPOSAL_STATUSES.SUBMITTED, PROPOSAL_STATUSES.UNDER_REVIEW, PROPOSAL_STATUSES.RESUBMITTED].includes(proposal.status)) {
    return ApiResponse.badRequest(res, 'Proposal is not in a reviewable state');
  }

  proposal.status = PROPOSAL_STATUSES.REJECTED;
  proposal.rejectionReason = reason;
  proposal.reviewedBy = req.user._id;
  proposal.reviewedAt = new Date();
  await proposal.save();

  await addHistory(proposal._id, PROPOSAL_STATUSES.REJECTED, req.user._id, reason);
  await logActivity({ proposalId: proposal._id, actor: req.user, action: ACTIVITY_ACTIONS.REJECTED, metadata: { reason } });

  await createNotification({
    userId: proposal.createdBy,
    type: NOTIFICATION_TYPES.PROPOSAL_REJECTED,
    title: 'Proposal Rejected',
    message: `Your proposal "${proposal.title}" was rejected. Reason: ${reason}`,
    relatedProposalId: proposal._id,
  });

  return ApiResponse.success(res, 'Proposal rejected', proposal);
});

// POST /api/v1/proposals/:id/resubmit
const resubmitProposal = asyncHandler(async (req, res) => {
  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  if (proposal.createdBy.toString() !== req.user._id.toString()) {
    return ApiResponse.forbidden(res, 'Not your proposal');
  }

  if (proposal.status !== PROPOSAL_STATUSES.REJECTED) {
    return ApiResponse.badRequest(res, 'Only rejected proposals can be resubmitted');
  }

  proposal.status = PROPOSAL_STATUSES.RESUBMITTED;
  proposal.submittedAt = new Date();
  await proposal.save();

  await addHistory(proposal._id, PROPOSAL_STATUSES.RESUBMITTED, req.user._id);
  await logActivity({ proposalId: proposal._id, actor: req.user, action: ACTIVITY_ACTIONS.RESUBMITTED });

  const fd = await getFinanceDirector();
  if (fd) {
    await createNotification({
      userId: fd._id,
      type: NOTIFICATION_TYPES.PROPOSAL_RESUBMITTED,
      title: 'Proposal Resubmitted',
      message: `"${proposal.title}" has been resubmitted by ${req.user.name}`,
      relatedProposalId: proposal._id,
    });
  }

  return ApiResponse.success(res, 'Proposal resubmitted', proposal);
});

// POST /api/v1/proposals/:id/bills
const uploadBills = asyncHandler(async (req, res) => {
  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  if (proposal.createdBy.toString() !== req.user._id.toString()) {
    return ApiResponse.forbidden(res, 'Not your proposal');
  }

  if (proposal.status !== PROPOSAL_STATUSES.WAITING_FOR_BILLS) {
    return ApiResponse.badRequest(res, 'Bills can only be uploaded when proposal is in Waiting for Bills status');
  }

  if (!req.files || req.files.length === 0) {
    return ApiResponse.badRequest(res, 'At least one bill file is required');
  }

  const amounts = Array.isArray(req.body.amounts) ? req.body.amounts : [req.body.amounts];

  req.files.forEach((file, i) => {
    const amount = amounts[i] ? parseFloat(amounts[i]) : 0;
    proposal.bills.push(buildBill(file, req.user._id, amount));
  });

  // Recalculate actual expense
  proposal.actualExpense = proposal.bills.reduce((sum, b) => sum + (b.amount || 0), 0);

  await proposal.save();

  await logActivity({ proposalId: proposal._id, actor: req.user, action: ACTIVITY_ACTIONS.BILLS_UPLOADED, metadata: { count: req.files.length } });

  const fd = await getFinanceDirector();
  if (fd) {
    await createNotification({
      userId: fd._id,
      type: NOTIFICATION_TYPES.BILLS_UPLOADED,
      title: 'Bills Uploaded',
      message: `${req.user.name} uploaded ${req.files.length} bill(s) for "${proposal.title}"`,
      relatedProposalId: proposal._id,
    });
  }

  return ApiResponse.success(res, 'Bills uploaded successfully', proposal);
});

// PATCH /api/v1/proposals/:id/bills/verify
const verifyBills = asyncHandler(async (req, res) => {
  const { billId, verificationStatus, verificationNote } = req.body;

  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  const bill = proposal.bills.id(billId);
  if (!bill) return ApiResponse.notFound(res, 'Bill not found');

  bill.verificationStatus = verificationStatus;
  bill.verificationNote = verificationNote || null;
  bill.verifiedBy = req.user._id;
  bill.verifiedAt = new Date();

  await proposal.save();

  await logActivity({ proposalId: proposal._id, actor: req.user, action: ACTIVITY_ACTIONS.BILLS_VERIFIED, metadata: { billId, verificationStatus } });

  await createNotification({
    userId: proposal.createdBy,
    type: NOTIFICATION_TYPES.BILLS_VERIFIED,
    title: 'Bill Verification Update',
    message: `A bill for "${proposal.title}" was marked as ${verificationStatus}${verificationNote ? `: ${verificationNote}` : ''}`,
    relatedProposalId: proposal._id,
  });

  return ApiResponse.success(res, 'Bill verification updated', proposal);
});

// PATCH /api/v1/proposals/:id/complete
const completeProposal = asyncHandler(async (req, res) => {
  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  if (proposal.status !== PROPOSAL_STATUSES.WAITING_FOR_BILLS) {
    return ApiResponse.badRequest(res, 'Proposal must be in Waiting for Bills status to complete');
  }

  if (proposal.bills.length === 0) {
    return ApiResponse.badRequest(res, 'No bills have been uploaded yet');
  }

  const allVerified = proposal.bills.every(
    (b) => b.verificationStatus === 'Verified' || b.verificationStatus === 'Completed'
  );

  if (!allVerified) {
    return ApiResponse.badRequest(res, 'All bills must be verified before completing the proposal');
  }

  proposal.status = PROPOSAL_STATUSES.COMPLETED;
  proposal.completedAt = new Date();
  await proposal.save();

  await addHistory(proposal._id, PROPOSAL_STATUSES.COMPLETED, req.user._id);
  await logActivity({ proposalId: proposal._id, actor: req.user, action: ACTIVITY_ACTIONS.COMPLETED });

  await createNotification({
    userId: proposal.createdBy,
    type: NOTIFICATION_TYPES.PROPOSAL_COMPLETED,
    title: 'Proposal Completed ✅',
    message: `Your proposal "${proposal.title}" has been marked as completed.`,
    relatedProposalId: proposal._id,
  });

  return ApiResponse.success(res, 'Proposal completed', proposal);
});

// GET /api/v1/proposals/:id/history
const getProposalHistory = asyncHandler(async (req, res) => {
  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  if (
    req.user.role === ROLES.DIRECTOR &&
    proposal.createdBy.toString() !== req.user._id.toString()
  ) {
    return ApiResponse.forbidden(res);
  }

  const history = await ProposalHistory.find({ proposalId: req.params.id })
    .populate('changedBy', 'name email role')
    .sort({ timestamp: 1 });

  return ApiResponse.success(res, 'Proposal history retrieved', history);
});

// GET /api/v1/proposals/:id/activity
const getProposalActivity = asyncHandler(async (req, res) => {
  const ActivityLog = require('../models/ActivityLog');

  const proposal = await Proposal.findOne({ _id: req.params.id, isDeleted: false });
  if (!proposal) return ApiResponse.notFound(res, 'Proposal not found');

  if (
    req.user.role === ROLES.DIRECTOR &&
    proposal.createdBy.toString() !== req.user._id.toString()
  ) {
    return ApiResponse.forbidden(res);
  }

  const logs = await ActivityLog.find({ proposalId: req.params.id })
    .populate('actorId', 'name email role')
    .sort({ timestamp: 1 });

  return ApiResponse.success(res, 'Activity log retrieved', logs);
});

// GET /api/v1/proposals/dashboard-stats (admin)
const getDashboardStats = asyncHandler(async (req, res) => {
  const [proposalStats, directorCount, recentProposals, upcomingDeadlines] = await Promise.all([
    Proposal.aggregate([
      { $match: { isDeleted: false } },
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]),
    User.countDocuments({ role: ROLES.DIRECTOR, isDeleted: false }),
    Proposal.find({ isDeleted: false })
      .populate('createdBy', 'name department')
      .sort({ updatedAt: -1 })
      .limit(5),
    Proposal.find({
      isDeleted: false,
      status: { $in: [PROPOSAL_STATUSES.SUBMITTED, PROPOSAL_STATUSES.UNDER_REVIEW, PROPOSAL_STATUSES.APPROVED] },
      requiredDate: { $gte: new Date(), $lte: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) },
    })
      .populate('createdBy', 'name department')
      .sort({ requiredDate: 1 })
      .limit(10),
  ]);

  const stats = {};
  proposalStats.forEach((s) => { stats[s._id] = s.count; });

  return ApiResponse.success(res, 'Dashboard stats retrieved', {
    directorCount,
    proposalStats: stats,
    totalProposals: Object.values(stats).reduce((a, b) => a + b, 0),
    recentProposals,
    upcomingDeadlines,
  });
});

// GET /api/v1/proposals/director-stats (director)
const getDirectorStats = asyncHandler(async (req, res) => {
  const [proposalStats, recentProposals, upcomingDeadlines] = await Promise.all([
    Proposal.aggregate([
      { $match: { isDeleted: false, createdBy: req.user._id } },
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]),
    Proposal.find({ isDeleted: false, createdBy: req.user._id })
      .sort({ updatedAt: -1 })
      .limit(5),
    Proposal.find({
      isDeleted: false,
      createdBy: req.user._id,
      status: { $in: [PROPOSAL_STATUSES.SUBMITTED, PROPOSAL_STATUSES.APPROVED] },
      requiredDate: { $gte: new Date() },
    })
      .sort({ requiredDate: 1 })
      .limit(5),
  ]);

  const stats = {};
  proposalStats.forEach((s) => { stats[s._id] = s.count; });

  return ApiResponse.success(res, 'Director stats retrieved', {
    proposalStats: stats,
    totalProposals: Object.values(stats).reduce((a, b) => a + b, 0),
    recentProposals,
    upcomingDeadlines,
  });
});

module.exports = {
  createProposal,
  updateProposal,
  submitProposal,
  getProposals,
  getProposalById,
  deleteProposal,
  approveProposal,
  rejectProposal,
  resubmitProposal,
  uploadBills,
  verifyBills,
  completeProposal,
  getProposalHistory,
  getProposalActivity,
  getDashboardStats,
  getDirectorStats,
};
