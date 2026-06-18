const express = require('express');
const router = express.Router();

const {
chatWithPaper,
getChatHistory
} = require('../controllers/chatController');

const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.route('/:id/chat')
.get(getChatHistory)
.post(chatWithPaper);

module.exports = router;
