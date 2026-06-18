const express = require('express');
const router = express.Router();

const searchController = require('../controllers/searchController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, searchController.searchPapers);
router.post('/ask', protect, searchController.askGlobalQuestion);

module.exports = router;
