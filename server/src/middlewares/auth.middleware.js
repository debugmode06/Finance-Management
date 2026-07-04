const { verifyAccessToken } = require('../utils/jwt');
const User = require('../models/User');
const ApiResponse = require('../utils/apiResponse');
const asyncHandler = require('../utils/asyncHandler');

const authenticate = asyncHandler(async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer ')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return ApiResponse.unauthorized(res, 'No authentication token provided');
  }

  let decoded;
  try {
    decoded = verifyAccessToken(token);
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return ApiResponse.unauthorized(res, 'Token expired. Please log in again.');
    }
    return ApiResponse.unauthorized(res, 'Invalid authentication token');
  }

  const user = await User.findById(decoded.id).select('+refreshToken');

  if (!user) {
    return ApiResponse.unauthorized(res, 'User no longer exists');
  }

  if (user.isDeleted) {
    return ApiResponse.unauthorized(res, 'Account has been deleted');
  }

  if (!user.isActive) {
    return ApiResponse.unauthorized(res, 'Account is deactivated. Contact admin.');
  }

  req.user = user;
  next();
});

module.exports = { authenticate };
