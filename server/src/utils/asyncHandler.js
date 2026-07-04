/**
 * Wraps async route handlers to avoid try/catch boilerplate.
 * Any thrown error is forwarded to the centralized error middleware.
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = asyncHandler;
