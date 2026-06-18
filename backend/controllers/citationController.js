const db = require('../config/db');

exports.getCitations = async (req, res) => {
  try {
    const paperId = req.params.id;
    const result = await db.query('SELECT citation_apa, citation_mla, citation_ieee FROM papers WHERE id = $1', [paperId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Paper not found" });
    }
    res.json({ success: true, citations: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.exportPaper = async (req, res) => {
  try {
    const paperId = req.params.id;
    const { format } = req.body; // e.g., 'pdf', 'bibtex'
    // Simulate export
    res.json({ 
      success: true, 
      downloadUrl: `https://api.example.com/exports/${paperId}.${format}`
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};