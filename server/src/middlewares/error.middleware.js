/**
 * Centralized error-handling middleware.
 * Always returns a consistent { success: false, message, ... } shape.
 * Never leaks stack traces in production.
 */
const errorHandler = (err, req, res, next) => {
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal server error';
  let errors = null;

  // Mongoose ValidationError
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation failed';
    errors = Object.values(err.errors).map((e) => ({
      field: e.path,
      message: e.message,
    }));
  }

  // Mongoose CastError (invalid ObjectId)
  if (err.name === 'CastError') {
    statusCode = 400;
    message = `Invalid ${err.path}: ${err.value}`;
  }

  // Mongoose Duplicate Key
  if (err.code === 11000) {
    statusCode = 409;
    const field = Object.keys(err.keyValue)[0];
    message = `${field.charAt(0).toUpperCase() + field.slice(1)} already exists`;
  }

  // Multer errors
  if (err.code === 'LIMIT_FILE_SIZE') {
    statusCode = 400;
    message = `File too large. Maximum size is ${
      parseInt(process.env.MAX_FILE_SIZE || 10485760) / (1024 * 1024)
    }MB`;
  }

  if (err.message && err.message.includes('Invalid file type')) {
    statusCode = 400;
    message = err.message;
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid token';
  }

  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token expired';
  }

  const isDev = process.env.NODE_ENV === 'development';

  const response = {
    success: false,
    message,
  };

  if (errors) response.errors = errors;
  if (isDev) response.stack = err.stack;

  console.error(`[ERROR] ${req.method} ${req.originalUrl} → ${statusCode}: ${message}`);

  res.status(statusCode).json(response);
};

module.exports = errorHandler;
