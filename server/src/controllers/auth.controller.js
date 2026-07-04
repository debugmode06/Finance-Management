const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/apiResponse');
const { signAccessToken, signRefreshToken } = require('../utils/jwt');
const { logActivity } = require('../services/activityLog.service');
const { ACTIVITY_ACTIONS } = require('../utils/constants');

// POST /api/v1/auth/login
const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({
    email: email.toLowerCase(),
    isDeleted: false,
  }).select('+passwordHash');

  if (!user) {
    return ApiResponse.unauthorized(res, 'Invalid email or password');
  }

  if (!user.isActive) {
    return ApiResponse.unauthorized(res, 'Your account is deactivated. Contact admin.');
  }

  const isMatch = await user.comparePassword(password);
  if (!isMatch) {
    return ApiResponse.unauthorized(res, 'Invalid email or password');
  }

  const payload = { id: user._id, role: user.role };
  const accessToken = signAccessToken(payload);
  const refreshToken = signRefreshToken(payload);

  // Store refresh token hash (optional — store the token itself for now)
  user.refreshToken = refreshToken;
  user.lastLoginAt = new Date();
  await user.save({ validateBeforeSave: false });

  await logActivity({
    actor: user,
    action: ACTIVITY_ACTIONS.LOGGED_IN,
    metadata: { email: user.email },
  });

  return ApiResponse.success(res, 'Login successful', {
    accessToken,
    refreshToken,
    user: {
      _id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      department: user.department,
      profileImage: user.profileImage,
      isActive: user.isActive,
    },
  });
});

// GET /api/v1/auth/me
const getMe = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  if (!user) return ApiResponse.notFound(res, 'User not found');
  return ApiResponse.success(res, 'User profile retrieved', user);
});

// POST /api/v1/auth/change-password
const changePassword = asyncHandler(async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  const user = await User.findById(req.user._id).select('+passwordHash');
  if (!user) return ApiResponse.notFound(res, 'User not found');

  const isMatch = await user.comparePassword(currentPassword);
  if (!isMatch) {
    return ApiResponse.badRequest(res, 'Current password is incorrect');
  }

  user.passwordHash = await User.hashPassword(newPassword);
  await user.save({ validateBeforeSave: false });

  await logActivity({
    actor: req.user,
    action: ACTIVITY_ACTIONS.PASSWORD_CHANGED,
    metadata: {},
  });

  return ApiResponse.success(res, 'Password changed successfully');
});

// POST /api/v1/auth/logout
const logout = asyncHandler(async (req, res) => {
  await User.findByIdAndUpdate(req.user._id, { refreshToken: null });

  await logActivity({
    actor: req.user,
    action: ACTIVITY_ACTIONS.LOGGED_OUT,
    metadata: {},
  });

  return ApiResponse.success(res, 'Logged out successfully');
});

module.exports = { login, getMe, changePassword, logout };
