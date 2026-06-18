const db = require('../config/db');

exports.getNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await db.query('SELECT * FROM notifications WHERE user_id = $1', [userId]);
    res.json({ success: true, notifications: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.markRead = async (req, res) => {
  try {
    const id = req.params.id;
    const result = await db.query('UPDATE notifications SET is_read = TRUE WHERE id = $1 RETURNING *', [id]);
    res.json({ success: true, notification: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};