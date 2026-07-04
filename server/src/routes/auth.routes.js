const express = require('express');
const router = express.Router();
const { login, getMe, changePassword, logout } = require('../controllers/auth.controller');
const { authenticate } = require('../middlewares/auth.middleware');
const { loginValidator, changePasswordValidator } = require('../validators/auth.validator');
const validate = require('../middlewares/validate.middleware');
const rateLimit = require('express-rate-limit');

const authLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: parseInt(process.env.AUTH_RATE_LIMIT_MAX) || 20,
  message: { success: false, message: 'Too many login attempts. Please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

router.post('/login', authLimiter, loginValidator, validate, login);
router.get('/me', authenticate, getMe);
router.post('/change-password', authenticate, changePasswordValidator, validate, changePassword);
router.post('/logout', authenticate, logout);

module.exports = router;
