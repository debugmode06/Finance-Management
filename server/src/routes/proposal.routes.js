const express = require('express');
const router = express.Router();
const {
  createProposal, updateProposal, submitProposal, getProposals,
  getProposalById, deleteProposal, approveProposal, rejectProposal,
  resubmitProposal, uploadBills, verifyBills, completeProposal,
  getProposalHistory, getProposalActivity, getDashboardStats, getDirectorStats,
} = require('../controllers/proposal.controller');
const { addComment, getComments } = require('../controllers/comment.controller');
const { authenticate } = require('../middlewares/auth.middleware');
const { authorize } = require('../middlewares/role.middleware');
const {
  createProposalValidator, rejectProposalValidator, addCommentValidator,
  verifyBillsValidator, approveProposalValidator,
} = require('../validators/proposal.validator');
const validate = require('../middlewares/validate.middleware');
const { uploadSingle, uploadMultiple } = require('../middlewares/upload.middleware');
const { ROLES } = require('../utils/constants');

const auth = authenticate;
const fd = [authenticate, authorize(ROLES.FINANCE_DIRECTOR)];
const dir = [authenticate, authorize(ROLES.DIRECTOR)];
const both = [authenticate, authorize(ROLES.FINANCE_DIRECTOR, ROLES.DIRECTOR)];

// Dashboard stats
router.get('/dashboard-stats', ...fd, getDashboardStats);
router.get('/director-stats', ...dir, getDirectorStats);

// CRUD
router.post('/', ...dir, uploadSingle('quotation'), createProposalValidator, validate, createProposal);
router.get('/', ...both, getProposals);
router.get('/:id', ...both, getProposalById);
router.put('/:id', ...dir, uploadSingle('quotation'), createProposalValidator, validate, updateProposal);
router.delete('/:id', ...dir, deleteProposal);

// Workflow
router.post('/:id/submit', ...dir, submitProposal);
router.patch('/:id/approve', ...fd, approveProposalValidator, validate, approveProposal);
router.patch('/:id/reject', ...fd, rejectProposalValidator, validate, rejectProposal);
router.post('/:id/resubmit', ...dir, resubmitProposal);
router.patch('/:id/complete', ...fd, completeProposal);

// Bills
router.post('/:id/bills', ...dir, uploadMultiple('bills', 10), uploadBills);
router.patch('/:id/bills/verify', ...fd, verifyBillsValidator, validate, verifyBills);

// History & Activity
router.get('/:id/history', ...both, getProposalHistory);
router.get('/:id/activity', ...both, getProposalActivity);

// Comments
router.post('/:id/comments', ...both, addCommentValidator, validate, addComment);
router.get('/:id/comments', ...both, getComments);

module.exports = router;
