const fs = require('fs');
const path = require('path');

/**
 * Abstracted storage service.
 * Currently uses local disk. Replace save/delete implementations
 * with Cloudinary SDK calls to migrate to cloud storage.
 */

const BASE_URL = process.env.BASE_URL || `http://localhost:${process.env.PORT || 5000}`;

/**
 * Get the public URL for a stored file
 * @param {string} filename - stored filename (not full path)
 */
const getFileUrl = (filename) => {
  return `${BASE_URL}/uploads/${filename}`;
};

/**
 * Delete a file by its URL or filename
 * @param {string} fileUrl - full URL or filename
 */
const deleteFile = async (fileUrl) => {
  try {
    const filename = fileUrl.split('/uploads/').pop();
    const filePath = path.join(process.cwd(), 'uploads', filename);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  } catch (error) {
    console.error('[StorageService] Failed to delete file:', error.message);
  }
};

/**
 * Build attachment object from multer file
 * @param {object} file - req.file from multer
 * @param {string} category - 'quotation' | 'bill' | 'other'
 * @param {string} uploadedBy - user ObjectId
 */
const buildAttachment = (file, category, uploadedBy) => ({
  url: getFileUrl(file.filename),
  fileName: file.originalname,
  fileType: file.mimetype,
  category,
  uploadedBy,
  uploadedAt: new Date(),
});

/**
 * Build bill object from multer file
 */
const buildBill = (file, uploadedBy, amount = 0) => ({
  url: getFileUrl(file.filename),
  fileName: file.originalname,
  fileType: file.mimetype,
  amount: parseFloat(amount) || 0,
  uploadedBy,
  uploadedAt: new Date(),
  verificationStatus: 'Pending',
});

module.exports = { getFileUrl, deleteFile, buildAttachment, buildBill };
