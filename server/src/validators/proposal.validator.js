const { body } = require('express-validator');
const { DEPARTMENTS, PROPOSAL_PRIORITIES } = require('../utils/constants');

const createProposalValidator = [
  body('title')
    .trim()
    .notEmpty().withMessage('Title is required')
    .isLength({ min: 5, max: 120 }).withMessage('Title must be between 5 and 120 characters'),
  body('eventName')
    .trim()
    .notEmpty().withMessage('Event name is required'),
  body('purpose')
    .trim()
    .notEmpty().withMessage('Purpose is required'),
  body('description')
    .trim()
    .notEmpty().withMessage('Description is required')
    .isLength({ min: 20 }).withMessage('Description must be at least 20 characters'),
  body('requestedBudget')
    .notEmpty().withMessage('Requested budget is required')
    .isFloat({ min: 0.01 }).withMessage('Budget must be greater than 0'),
  body('priority')
    .notEmpty().withMessage('Priority is required')
    .isIn(Object.values(PROPOSAL_PRIORITIES)).withMessage(`Priority must be one of: ${Object.values(PROPOSAL_PRIORITIES).join(', ')}`),
  body('requiredDate')
    .notEmpty().withMessage('Required date is required')
    .isISO8601().withMessage('Invalid date format')
    .custom((value) => {
      const date = new Date(value);
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      if (date < today) {
        throw new Error('Required date must be today or in the future');
      }
      return true;
    }),
  body('notes').optional(),
];

const rejectProposalValidator = [
  body('reason')
    .trim()
    .notEmpty().withMessage('Rejection reason is required')
    .isLength({ min: 10 }).withMessage('Rejection reason must be at least 10 characters'),
];

const addCommentValidator = [
  body('message')
    .trim()
    .notEmpty().withMessage('Comment message is required')
    .isLength({ max: 2000 }).withMessage('Comment cannot exceed 2000 characters'),
];

const verifyBillsValidator = [
  body('billId').notEmpty().withMessage('Bill ID is required'),
  body('verificationStatus')
    .notEmpty().withMessage('Verification status is required')
    .isIn(['Verified', 'Need Correction', 'Completed']).withMessage('Invalid verification status'),
  body('verificationNote').optional(),
];

const approveProposalValidator = [
  body('approvedBudget')
    .notEmpty().withMessage('Approved budget is required')
    .isFloat({ min: 0 }).withMessage('Approved budget must be a non-negative number'),
];

module.exports = {
  createProposalValidator,
  rejectProposalValidator,
  addCommentValidator,
  verifyBillsValidator,
  approveProposalValidator,
};
