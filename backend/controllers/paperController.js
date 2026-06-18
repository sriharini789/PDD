const prisma = require('../config/prisma');
const pdfService = require('../services/pdfService');
const aiService = require('../services/aiService');
const analysisEngine = require('../services/analysisEngine');

exports.uploadPaper = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No PDF file uploaded.' });
    }
    const userId = req.user.id;

    // 1. Create DB Record
    const paper = await prisma.paper.create({
      data: {
        userId,
        title: req.file.originalname,
        authors: 'Processing...',
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
        const pdfResult = await pdfService.extractTextFromPDF(req.file.buffer);
        const text = pdfResult.text;
        const numpages = pdfResult.numpages;

        await prisma.paper.update({
          where: { id: paper.id },
          data: {
            processingStage: 'analyzing',
            content: text.substring(0, 100000)
          }
        });
        
        // 3. Perform Comprehensive Local Analysis (Offline-first)
        const localAnalysis = await analysisEngine.analyzeLocal(text, numpages);

        // 4. Try AI Enhancement (Optional, fallback to local if it fails)
        let finalAnalysis = localAnalysis;
        try {
          // If Gemini fails, this catch block ensures the app never shows "Failed"
          const aiAnalysis = await aiService.analyzePaper(text);
          // Merge AI results over local results where applicable
          finalAnalysis = { ...localAnalysis, ...aiAnalysis };
        } catch (aiErr) {
          console.warn("Gemini API failed, continuing with local engine results.");
        }
        
        // 5. Update DB with results
        await prisma.paper.update({
          where: { id: paper.id },
          data: {
            title: finalAnalysis.extractedContent?.title || paper.title,
            authors: finalAnalysis.extractedContent?.authors || 'Unknown',
            summary: finalAnalysis.summaries?.detailed || finalAnalysis.summaries?.short || "Analysis complete.",
            topics: finalAnalysis.topicsExt?.main || ["Extracted"],
            citationApa: finalAnalysis.citations?.apa || "",
            citationMla: finalAnalysis.citations?.mla || "",
            citationIeee: finalAnalysis.citations?.ieee || "",
            
            verification: finalAnalysis.verification || {},
            summaries: finalAnalysis.summaries || {},
            insights: finalAnalysis.insights || {},
            topicsExt: finalAnalysis.topicsExt || {},
            citations: finalAnalysis.citations || {},
            extractedContent: finalAnalysis.extractedContent || {},
            references: finalAnalysis.references || [],
            metrics: finalAnalysis.metrics || {
              totalPages: numpages,
              totalWords: text.split(/\s+/).length,
              readingTime: Math.ceil(text.split(/\s+/).length / 200) + ' min',
              totalReferences: 0,
            },

            processingStage: 'done',
            status: 'completed'
          }
        });

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