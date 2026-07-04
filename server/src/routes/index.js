const express = require('express');
const router = express.Router();

const authRoutes = require('./auth.routes');
const userRoutes = require('./user.routes');
const proposalRoutes = require('./proposal.routes');
const notificationRoutes = require('./notification.routes');
const reportRoutes = require('./report.routes');

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/proposals', proposalRoutes);
router.use('/notifications', notificationRoutes);
router.use('/reports', reportRoutes);

// Health check
router.get('/health', (req, res) => {
  res.json({ success: true, message: 'CSEA Finance API is running', timestamp: new Date() });
});

module.exports = router;
