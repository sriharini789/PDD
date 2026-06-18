const db = require('../config/db');

exports.getLibrary = async (req, res) => {
  try {
    const userId = req.user.id;
    const papersResult = await db.query('SELECT * FROM papers WHERE user_id = $1', [userId]);
    const listsResult = await db.query('SELECT * FROM reading_lists WHERE user_id = $1', [userId]);
    
    res.json({ 
      success: true, 
      papers: papersResult.rows,
      readingLists: listsResult.rows 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.createReadingList = async (req, res) => {
  try {
    const userId = req.user.id;
    const { name } = req.body;
    const result = await db.query(
      'INSERT INTO reading_lists (user_id, name) VALUES ($1, $2) RETURNING *',
      [userId, name]
    );
    res.json({ success: true, list: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.toggleFavorite = async (req, res) => {
  try {
    const paperId = req.params.id;
    const { is_favorite } = req.body;
    const result = await db.query(
      'UPDATE papers SET is_favorite = $1 WHERE id = $2 RETURNING *',
      [is_favorite, paperId]
    );
    res.json({ success: true, paper: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};