const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/apiResponse');
const { logActivity } = require('../services/activityLog.service');
const { ACTIVITY_ACTIONS, ROLES } = require('../utils/constants');
const { buildAttachment } = require('../services/storage.service');
const { getFileUrl } = require('../services/storage.service');

// POST /api/v1/users — Create director (finance_director only)
const createUser = asyncHandler(async (req, res) => {
  const { name, email, phone, department, password } = req.body;

  const existing = await User.findOne({ email: email.toLowerCase() });
  if (existing) {
    return ApiResponse.badRequest(res, 'Email already registered');
  }

  const passwordHash = await User.hashPassword(password);

  const user = await User.create({
    name,
    email: email.toLowerCase(),
    phone,
    department,
    role: ROLES.DIRECTOR,
    passwordHash,
  });

  await logActivity({
    actor: req.user,
    action: ACTIVITY_ACTIONS.DIRECTOR_CREATED,
    metadata: { directorId: user._id, name, email, department },
  });

  return ApiResponse.created(res, 'Director created successfully', user);
});

// GET /api/v1/users — List directors
const getUsers = asyncHandler(async (req, res) => {
  const {
    search,
    department,
    isActive,
    page = 1,
    limit = 20,
    sortBy = 'createdAt',
    order = 'desc',
  } = req.query;

  const query = { isDeleted: false };

  // Finance director can see everyone; directors see only themselves
  if (req.user.role !== ROLES.FINANCE_DIRECTOR) {
    query._id = req.user._id;
  } else {
    // Filter directors only in the list
    query.role = ROLES.DIRECTOR;
  }

  if (search) {
    query.$or = [
      { name: { $regex: search, $options: 'i' } },
      { email: { $regex: search, $options: 'i' } },
      { department: { $regex: search, $options: 'i' } },
    ];
  }

  if (department) query.department = department;
  if (isActive !== undefined) query.isActive = isActive === 'true';

  const skip = (parseInt(page) - 1) * parseInt(limit);
  const sortOrder = order === 'asc' ? 1 : -1;

  const [users, total] = await Promise.all([
    User.find(query)
      .sort({ [sortBy]: sortOrder })
      .skip(skip)
      .limit(parseInt(limit)),
    User.countDocuments(query),
  ]);

  return ApiResponse.success(res, 'Directors retrieved', users, {
    total,
    page: parseInt(page),
    limit: parseInt(limit),
    totalPages: Math.ceil(total / parseInt(limit)),
  });
});

// GET /api/v1/users/:id
const getUserById = asyncHandler(async (req, res) => {
  const user = await User.findOne({ _id: req.params.id, isDeleted: false });
  if (!user) return ApiResponse.notFound(res, 'User not found');

  // Directors can only view their own profile via this endpoint
  if (
    req.user.role !== ROLES.FINANCE_DIRECTOR &&
    user._id.toString() !== req.user._id.toString()
  ) {
    return ApiResponse.forbidden(res);
  }

  return ApiResponse.success(res, 'User retrieved', user);
});

// PUT /api/v1/users/:id
const updateUser = asyncHandler(async (req, res) => {
  const { name, phone, department } = req.body;

  const user = await User.findOne({ _id: req.params.id, isDeleted: false });
  if (!user) return ApiResponse.notFound(res, 'User not found');

  if (req.user.role !== ROLES.FINANCE_DIRECTOR) {
    return ApiResponse.forbidden(res);
  }

  if (name) user.name = name;
  if (phone !== undefined) user.phone = phone;
  if (department) user.department = department;

  // Handle profile image upload
  if (req.file) {
    user.profileImage = getFileUrl(req.file.filename);
  }

  await user.save();

  await logActivity({
    actor: req.user,
    action: ACTIVITY_ACTIONS.DIRECTOR_UPDATED,
    metadata: { directorId: user._id, changes: { name, phone, department } },
  });

  return ApiResponse.success(res, 'User updated successfully', user);
});

// DELETE /api/v1/users/:id (soft delete)
const deleteUser = asyncHandler(async (req, res) => {
  const user = await User.findOne({ _id: req.params.id, isDeleted: false });
  if (!user) return ApiResponse.notFound(res, 'User not found');

  if (user.role === ROLES.FINANCE_DIRECTOR) {
    return ApiResponse.badRequest(res, 'Cannot delete the Finance Director account');
  }

  user.isDeleted = true;
  user.isActive = false;
  await user.save({ validateBeforeSave: false });

  await logActivity({
    actor: req.user,
    action: ACTIVITY_ACTIONS.DIRECTOR_DELETED,
    metadata: { directorId: user._id, name: user.name },
  });

  return ApiResponse.success(res, 'Director deleted successfully');
});

// PATCH /api/v1/users/:id/activate
const activateUser = asyncHandler(async (req, res) => {
  const user = await User.findOne({ _id: req.params.id, isDeleted: false });
  if (!user) return ApiResponse.notFound(res, 'User not found');

  user.isActive = true;
  await user.save({ validateBeforeSave: false });

  await logActivity({
    actor: req.user,
    action: ACTIVITY_ACTIONS.DIRECTOR_ACTIVATED,
    metadata: { directorId: user._id },
  });

  return ApiResponse.success(res, 'Director activated successfully', user);
});

// PATCH /api/v1/users/:id/deactivate
const deactivateUser = asyncHandler(async (req, res) => {
  const user = await User.findOne({ _id: req.params.id, isDeleted: false });
  if (!user) return ApiResponse.notFound(res, 'User not found');

  if (user.role === ROLES.FINANCE_DIRECTOR) {
    return ApiResponse.badRequest(res, 'Cannot deactivate the Finance Director account');
  }

  user.isActive = false;
  await user.save({ validateBeforeSave: false });

  await logActivity({
    actor: req.user,
    action: ACTIVITY_ACTIONS.DIRECTOR_DEACTIVATED,
    metadata: { directorId: user._id },
  });

  return ApiResponse.success(res, 'Director deactivated successfully', user);
});

// POST /api/v1/users/:id/reset-password
const resetPassword = asyncHandler(async (req, res) => {
  const { newPassword } = req.body;

  const user = await User.findOne({ _id: req.params.id, isDeleted: false });
  if (!user) return ApiResponse.notFound(res, 'User not found');

  user.passwordHash = await User.hashPassword(newPassword);
  await user.save({ validateBeforeSave: false });

  await logActivity({
    actor: req.user,
    action: ACTIVITY_ACTIONS.PASSWORD_RESET,
    metadata: { directorId: user._id },
  });

  return ApiResponse.success(res, 'Password reset successfully');
});

// GET /api/v1/users/me
const getMyProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  return ApiResponse.success(res, 'Profile retrieved', user);
});

// PUT /api/v1/users/me
const updateMyProfile = asyncHandler(async (req, res) => {
  const { name, phone } = req.body;

  const user = await User.findById(req.user._id);
  if (!user) return ApiResponse.notFound(res, 'User not found');

  if (name) user.name = name;
  if (phone !== undefined) user.phone = phone;

  if (req.file) {
    user.profileImage = getFileUrl(req.file.filename);
  }

  await user.save();

  await logActivity({
    actor: req.user,
    action: ACTIVITY_ACTIONS.PROFILE_UPDATED,
    metadata: { changes: { name, phone } },
  });

  return ApiResponse.success(res, 'Profile updated successfully', user);
});

module.exports = {
  createUser,
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
  activateUser,
  deactivateUser,
  resetPassword,
  getMyProfile,
  updateMyProfile,
};
