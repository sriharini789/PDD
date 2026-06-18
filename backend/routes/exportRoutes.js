const express = require('express');
const router = express.Router();
const exportController = require('../controllers/exportController');
const { protect } = require('../middleware/authMiddleware');

router.get('/:id/pdf', protect, exportController.exportPdf);
router.get('/:id/docx', protect, exportController.exportDocx);
router.get('/:id/txt', protect, exportController.exportTxt);
router.get('/:id/md', protect, exportController.exportMarkdown);

module.exports = router;
