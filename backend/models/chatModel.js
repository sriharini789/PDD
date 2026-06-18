const db = require('../config/db');

const createChatTable = async () => {
  const queryText = `
    CREATE TABLE IF NOT EXISTS chat_messages (
      id SERIAL PRIMARY KEY,
      paper_id INT NOT NULL REFERENCES papers(id) ON DELETE CASCADE,
      user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      sender VARCHAR(10) NOT NULL,
      message TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;
  try {
    await db.query(queryText);
    console.log("Chat messages table verified/created successfully.");
  } catch (err) {
    console.error("Error creating chat messages table:", err.message);
    throw err;
  }
};

const addMessage = async (paperId, userId, sender, message) => {
  const queryText = `
    INSERT INTO chat_messages (paper_id, user_id, sender, message)
    VALUES ($1, $2, $3, $4)
    RETURNING *;
  `;
  const res = await db.query(queryText, [paperId, userId, sender, message]);
  return res.rows[0];
};

const findByPaperId = async (paperId) => {
  const queryText = `
    SELECT * FROM chat_messages
    WHERE paper_id = $1
    ORDER BY created_at ASC;
  `;
  const res = await db.query(queryText, [paperId]);
  return res.rows;
};

module.exports = {
  createChatTable,
  addMessage,
  findByPaperId
};
