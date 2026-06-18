const express = require('express');
const router = express.Router();

const libraryController = require('../controllers/libraryController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, libraryController.getLibrary);

router.post(
  '/reading-list',
  protect,
  libraryController.createReadingList
);

router.post(
  '/papers/:id/favorite',
  protect,
  libraryController.toggleFavorite
);

module.exports = router;