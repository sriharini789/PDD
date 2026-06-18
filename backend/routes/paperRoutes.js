const express = require('express');
const router = express.Router();
const multer = require('multer');
const paperController = require('../controllers/paperController');
const { protect } = require('../middleware/authMiddleware');

const upload = multer({ storage: multer.memoryStorage() });

router.post('/upload', protect, upload.single('file'), paperController.uploadPaper);
router.get('/', protect, paperController.getPapers);
router.get('/:id', protect, paperController.getPaperDetail);

module.exports = router;