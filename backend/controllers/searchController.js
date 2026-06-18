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