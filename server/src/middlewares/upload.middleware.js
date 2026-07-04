const multerConfig = require('../config/multer');

/**
 * Single file upload for a given field name
 */
const uploadSingle = (fieldName) => (req, res, next) => {
  multerConfig.single(fieldName)(req, res, (err) => {
    if (err) return next(err);
    next();
  });
};

/**
 * Multiple files upload (up to maxCount) for a given field name
 */
const uploadMultiple = (fieldName, maxCount = 10) => (req, res, next) => {
  multerConfig.array(fieldName, maxCount)(req, res, (err) => {
    if (err) return next(err);
    next();
  });
};

/**
 * Multiple fields
 */
const uploadFields = (fields) => (req, res, next) => {
  multerConfig.fields(fields)(req, res, (err) => {
    if (err) return next(err);
    next();
  });
};

module.exports = { uploadSingle, uploadMultiple, uploadFields };
