const express = require('express');
const router = express.Router();

const citationController = require('../controllers/citationController');
const { protect } = require('../middleware/authMiddleware');

router.get(
'/papers/:id/citations',
protect,
citationController.getCitations
);

router.post(
'/papers/:id/export',
protect,
citationController.exportPaper
);

module.exports = router;
