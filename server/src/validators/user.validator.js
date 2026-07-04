const { body } = require('express-validator');
const { DEPARTMENTS, ROLES } = require('../utils/constants');

const createUserValidator = [
  body('name')
    .trim()
    .notEmpty().withMessage('Name is required')
    .isLength({ max: 100 }).withMessage('Name cannot exceed 100 characters'),
  body('email')
    .isEmail().withMessage('Valid email is required')
    .normalizeEmail(),
  body('phone')
    .optional()
    .isMobilePhone().withMessage('Invalid phone number'),
  body('department')
    .notEmpty().withMessage('Department is required')
    .isIn(Object.values(DEPARTMENTS)).withMessage(`Department must be one of: ${Object.values(DEPARTMENTS).join(', ')}`),
  body('password')
    .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain uppercase, lowercase, and a number'),
];

const updateUserValidator = [
  body('name')
    .optional()
    .trim()
    .notEmpty().withMessage('Name cannot be empty')
    .isLength({ max: 100 }).withMessage('Name cannot exceed 100 characters'),
  body('phone')
    .optional()
    .isMobilePhone().withMessage('Invalid phone number'),
  body('department')
    .optional()
    .isIn(Object.values(DEPARTMENTS)).withMessage(`Department must be one of: ${Object.values(DEPARTMENTS).join(', ')}`),
];

const resetPasswordValidator = [
  body('newPassword')
    .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain uppercase, lowercase, and a number'),
];

module.exports = { createUserValidator, updateUserValidator, resetPasswordValidator };
