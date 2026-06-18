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