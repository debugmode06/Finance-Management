const path = require('path');
const Proposal = require('../models/Proposal');
const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/apiResponse');
const { generatePDF, generateExcel } = require('../services/report.service');
const { PROPOSAL_STATUSES, DEPARTMENTS } = require('../utils/constants');

// GET /api/v1/reports/export?format=pdf|excel&period=&department=&status=
const exportReport = asyncHandler(async (req, res) => {
  const { format = 'pdf', period, department, status, startDate, endDate } = req.query;

  const query = { isDeleted: false };

  if (department && Object.values(DEPARTMENTS).includes(department)) {
    query.department = department;
  }

  if (status) {
    const statuses = status.split(',');
    query.status = statuses.length > 1 ? { $in: statuses } : statuses[0];
  }

  // Date range by period
  const now = new Date();
  if (period === 'monthly') {
    const start = new Date(now.getFullYear(), now.getMonth(), 1);
    query.createdAt = { $gte: start };
  } else if (period === 'semester') {
    const month = now.getMonth();
    const semStart = month < 6
      ? new Date(now.getFullYear(), 0, 1)
      : new Date(now.getFullYear(), 6, 1);
    query.createdAt = { $gte: semStart };
  } else if (period === 'academic_year') {
    const yearStart = now.getMonth() >= 8
      ? new Date(now.getFullYear(), 8, 1)
      : new Date(now.getFullYear() - 1, 8, 1);
    query.createdAt = { $gte: yearStart };
  } else if (startDate || endDate) {
    query.createdAt = {};
    if (startDate) query.createdAt.$gte = new Date(startDate);
    if (endDate) query.createdAt.$lte = new Date(endDate);
  }

  const proposals = await Proposal.find(query)
    .populate('createdBy', 'name email department')
    .populate('reviewedBy', 'name email')
    .sort({ createdAt: -1 });

  const filters = { period, department, status };

  let result;
  if (format === 'excel') {
    result = await generateExcel(proposals, filters);
  } else {
    result = await generatePDF(proposals, filters);
  }

  const mimeType = format === 'excel'
    ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    : 'application/pdf';

  res.setHeader('Content-Disposition', `attachment; filename="${result.filename}"`);
  res.setHeader('Content-Type', mimeType);

  return res.sendFile(result.filePath, (err) => {
    if (err) {
      console.error('[Report] Error sending file:', err.message);
    }
  });
});

module.exports = { exportReport };
