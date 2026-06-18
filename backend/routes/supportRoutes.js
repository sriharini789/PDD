const express = require('express');
const router = express.Router();

const supportController = require('../controllers/supportController');
const { protect } = require('../middleware/authMiddleware');

router.post(
  '/contact',
  protect,
  supportController.submitContact
);

router.post(
  '/feedback',
  protect,
  supportController.submitFeedback
);

module.exports = router;