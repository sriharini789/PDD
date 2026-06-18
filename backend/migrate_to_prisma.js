const fs = require('fs');
const path = require('path');

const controllersDir = path.join(__dirname, 'controllers');

// Rewrite paperController.js
const paperControllerContent = `
const prisma = require('../config/prisma');
const pdfService = require('../services/pdfService');
const aiService = require('../services/aiService');

exports.uploadPaper = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No PDF file uploaded.' });
    }
    const userId = req.user.id;
    const { title, authors } = req.body;
    
    // 1. Create DB Record
    const paper = await prisma.paper.create({
      data: {
        userId,
        title: title || req.file.originalname,
        authors: authors || 'Unknown',
        fileName: req.file.originalname,
        fileSize: (req.file.size / 1024 / 1024).toFixed(2) + 'MB',
        status: 'processing',
        processingStage: 'extracting'
      }
    });

    res.json({ success: true, paper });

    // --- Background Processing ---
    setImmediate(async () => {
      try {
        // 2. Extract Text
        const text = await pdfService.extractTextFromPDF(req.file.buffer);
        await prisma.paper.update({ where: { id: paper.id }, data: { processingStage: 'analyzing', content: text.substring(0, 50000) } });
        
        // 3. AI Summarization & Citation
        const aiAnalysis = await aiService.analyzePaper(text);
        await prisma.paper.update({
          where: { id: paper.id },
          data: {
            summary: aiAnalysis.summary,
            topics: aiAnalysis.topics,
            citationApa: aiAnalysis.citationApa,
            citationMla: aiAnalysis.citationMla,
            citationIeee: aiAnalysis.citationIeee,
            processingStage: 'embedding'
          }
        });

        // 4. Vector DB Embeddings
        await aiService.processAndStoreDocument(paper.id, text);
        
        // 5. Complete
        await prisma.paper.update({ where: { id: paper.id }, data: { status: 'completed', processingStage: 'done' } });
      } catch (err) {
        console.error("Background Processing Error:", err);
        await prisma.paper.update({ where: { id: paper.id }, data: { status: 'failed' } });
      }
    });

  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getPapers = async (req, res) => {
  try {
    const papers = await prisma.paper.findMany({ where: { userId: req.user.id }, orderBy: { createdAt: 'desc' } });
    res.json({ success: true, papers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getPaperDetail = async (req, res) => {
  try {
    const paper = await prisma.paper.findUnique({ where: { id: parseInt(req.params.id) } });
    res.json({ success: true, paper });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
`;

fs.writeFileSync(path.join(controllersDir, 'paperController.js'), paperControllerContent.trim());

// Rewrite chatController.js
const chatControllerContent = `
const prisma = require('../config/prisma');
const aiService = require('../services/aiService');

exports.chatWithPaper = async (req, res) => {
  try {
    const paperId = parseInt(req.params.id);
    const userId = req.user.id;
    const { message } = req.body;

    // 1. Save user message
    const userMsg = await prisma.chatMessage.create({
      data: { paperId, userId, sender: 'user', message }
    });

    // 2. Query RAG
    const aiAnswer = await aiService.chatWithPaper(paperId, message);

    // 3. Save AI response
    const aiMsg = await prisma.chatMessage.create({
      data: { paperId, userId, sender: 'ai', message: aiAnswer }
    });

    res.json({ success: true, answer: aiMsg });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getChatHistory = async (req, res) => {
  try {
    const paperId = parseInt(req.params.id);
    const messages = await prisma.chatMessage.findMany({ where: { paperId }, orderBy: { createdAt: 'asc' } });
    res.json({ success: true, messages });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
`;
fs.writeFileSync(path.join(controllersDir, 'chatController.js'), chatControllerContent.trim());

// Add Multer to paperRoutes.js
const routesDir = path.join(__dirname, 'routes');
const paperRoutesContent = `
const express = require('express');
const router = express.Router();
const multer = require('multer');
const paperController = require('../controllers/paperController');
const authMiddleware = require('../middleware/authMiddleware');

const upload = multer({ storage: multer.memoryStorage() });

router.post('/upload', authMiddleware, upload.single('file'), paperController.uploadPaper);
router.get('/', authMiddleware, paperController.getPapers);
router.get('/:id', authMiddleware, paperController.getPaperDetail);

module.exports = router;
`;
fs.writeFileSync(path.join(routesDir, 'paperRoutes.js'), paperRoutesContent.trim());

// Modify searchController.js to support Lit Review and Advanced Features
const searchControllerContent = `
const prisma = require('../config/prisma');
const aiService = require('../services/aiService');

exports.searchPapers = async (req, res) => {
  try {
    const { q } = req.query;
    const papers = await prisma.paper.findMany({
      where: {
        OR: [
          { title: { contains: q, mode: 'insensitive' } },
          { summary: { contains: q, mode: 'insensitive' } }
        ]
      }
    });
    res.json({ success: true, results: papers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.askGlobalQuestion = async (req, res) => {
  try {
    const { question } = req.body;
    const answer = await aiService.generateLiteratureReview(question);
    res.json({ success: true, answer, sources: [] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
`;
fs.writeFileSync(path.join(controllersDir, 'searchController.js'), searchControllerContent.trim());

console.log("Controllers successfully migrated to Prisma and AI Services.");
