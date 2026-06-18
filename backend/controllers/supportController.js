const db = require('../config/db');

exports.submitContact = async (req, res) => {
  try {
    const userId = req.user.id;
    const { subject, description } = req.body;
    const result = await db.query(
      'INSERT INTO support_tickets (user_id, subject, description) VALUES ($1, $2, $3) RETURNING *',
      [userId, subject, description]
    );
    res.json({ success: true, ticket: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.submitFeedback = async (req, res) => {
  try {
    const userId = req.user.id;
    const { rating, comment } = req.body;
    const result = await db.query(
      'INSERT INTO feedback (user_id, rating, comment) VALUES ($1, $2, $3) RETURNING *',
      [userId, rating, comment]
    );
    res.json({ success: true, feedback: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};