const express = require('express');
const router = express.Router();
const { exportReport } = require('../controllers/report.controller');
const { authenticate } = require('../middlewares/auth.middleware');
const { authorize } = require('../middlewares/role.middleware');
const { ROLES } = require('../utils/constants');

router.get('/export', authenticate, authorize(ROLES.FINANCE_DIRECTOR), exportReport);

module.exports = router;
