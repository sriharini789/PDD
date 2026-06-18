const db = require('../config/db');

exports.getSettings = async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await db.query('SELECT * FROM settings WHERE user_id = $1', [userId]);
    res.json({ success: true, settings: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updateSettings = async (req, res) => {
  try {
    const userId = req.user.id;
    const { dark_mode, ai_model, privacy_telemetry } = req.body;
    const result = await db.query(
      'UPDATE settings SET dark_mode = $1, ai_model = $2, privacy_telemetry = $3 WHERE user_id = $4 RETURNING *',
      [dark_mode, ai_model, privacy_telemetry, userId]
    );
    res.json({ success: true, settings: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};