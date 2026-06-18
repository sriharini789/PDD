const express = require('express');
const router = express.Router();
const {
  signup,
  login,
  verifyEmail,
  forgotPassword,
  resetPassword,
  getMe
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

router.post('/signup', signup);
router.post('/login', login);

// Supports GET for clicking verification link in browser
// Supports POST for app client verification
router.route('/verify-email')
  .get(verifyEmail)
  .post(verifyEmail);

router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

router.get('/me', protect, getMe);

module.exports = router;
