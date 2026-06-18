const db = require('../config/db');

exports.getNotes = async (req, res) => {
  try {
    const paperId = req.params.id;
    const result = await db.query('SELECT * FROM notes WHERE paper_id = $1', [paperId]);
    res.json({ success: true, notes: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.addNote = async (req, res) => {
  try {
    const paperId = req.params.id;
    const userId = req.user.id;
    const { content, highlighted_text, page_number } = req.body;
    
    const result = await db.query(
      'INSERT INTO notes (paper_id, user_id, content, highlighted_text, page_number) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [paperId, userId, content, highlighted_text, page_number]
    );
    res.json({ success: true, note: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};