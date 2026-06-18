const express = require('express');
const router = express.Router();
const { getProfile, upsertProfile } = require('../controllers/profileController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect); // Secure all profile routes

router.route('/')
  .get(getProfile)
  .post(upsertProfile);

module.exports = router;
