const express = require('express');
const router = express.Router();
const {
  createUser, getUsers, getUserById, updateUser, deleteUser,
  activateUser, deactivateUser, resetPassword, getMyProfile, updateMyProfile,
} = require('../controllers/user.controller');
const { authenticate } = require('../middlewares/auth.middleware');
const { authorize } = require('../middlewares/role.middleware');
const { createUserValidator, updateUserValidator, resetPasswordValidator } = require('../validators/user.validator');
const validate = require('../middlewares/validate.middleware');
const { uploadSingle } = require('../middlewares/upload.middleware');
const { ROLES } = require('../utils/constants');

// Self endpoints (any authenticated user)
router.get('/me', authenticate, getMyProfile);
router.put('/me', authenticate, uploadSingle('profileImage'), updateMyProfile);

// Finance director only
router.post('/', authenticate, authorize(ROLES.FINANCE_DIRECTOR), createUserValidator, validate, createUser);
router.get('/', authenticate, authorize(ROLES.FINANCE_DIRECTOR), getUsers);
router.get('/:id', authenticate, authorize(ROLES.FINANCE_DIRECTOR), getUserById);
router.put('/:id', authenticate, authorize(ROLES.FINANCE_DIRECTOR), updateUserValidator, validate, uploadSingle('profileImage'), updateUser);
router.delete('/:id', authenticate, authorize(ROLES.FINANCE_DIRECTOR), deleteUser);
router.patch('/:id/activate', authenticate, authorize(ROLES.FINANCE_DIRECTOR), activateUser);
router.patch('/:id/deactivate', authenticate, authorize(ROLES.FINANCE_DIRECTOR), deactivateUser);
router.post('/:id/reset-password', authenticate, authorize(ROLES.FINANCE_DIRECTOR), resetPasswordValidator, validate, resetPassword);

module.exports = router;
