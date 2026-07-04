const ApiResponse = require('../utils/apiResponse');

/**
 * Role-Based Access Control middleware factory.
 * Usage: authorize('finance_director') or authorize('finance_director', 'director')
 */
const authorize = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return ApiResponse.unauthorized(res, 'Not authenticated');
    }

    if (!allowedRoles.includes(req.user.role)) {
      return ApiResponse.forbidden(
        res,
        `Access denied. Required role(s): ${allowedRoles.join(', ')}`
      );
    }

    next();
  };
};

module.exports = { authorize };
