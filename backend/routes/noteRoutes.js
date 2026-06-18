const express = require('express');
const router = express.Router();

const noteController = require('../controllers/noteController');
const { protect } = require('../middleware/authMiddleware');

router.get(
'/papers/:id/notes',
protect,
noteController.getNotes
);

router.post(
'/papers/:id/notes',
protect,
noteController.addNote
);

module.exports = router;
