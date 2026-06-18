const db = require('../config/db');

const createPaperTable = async () => {
  const queryText = `
    CREATE TABLE IF NOT EXISTS papers (
      id SERIAL PRIMARY KEY,
      user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      title VARCHAR(255) NOT NULL,
      authors VARCHAR(255) NOT NULL,
      file_name VARCHAR(255) NOT NULL,
      file_size VARCHAR(50) NOT NULL,
      status VARCHAR(50) NOT NULL DEFAULT 'uploading',
      processing_stage VARCHAR(50) NOT NULL DEFAULT 'extracting',
      summary TEXT,
      topics TEXT[] DEFAULT '{}',
      content TEXT,
      citation_apa TEXT,
      citation_mla TEXT,
      citation_ieee TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;
  try {
    await db.query(queryText);
    console.log("Papers table verified/created successfully.");
  } catch (err) {
    console.error("Error creating papers table:", err.message);
    throw err;
  }
};

const create = async (paperData) => {
  const queryText = `
    INSERT INTO papers (
      user_id, title, authors, file_name, file_size, 
      status, processing_stage, summary, topics, content, 
      citation_apa, citation_mla, citation_ieee
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
    RETURNING *;
  `;
  const res = await db.query(queryText, [
    paperData.userId,
    paperData.title,
    paperData.authors || 'Unknown Authors',
    paperData.fileName,
    paperData.fileSize,
    paperData.status || 'uploading',
    paperData.processingStage || 'extracting',
    paperData.summary || '',
    paperData.topics || [],
    paperData.content || '',
    paperData.citationApa || '',
    paperData.citationMla || '',
    paperData.citationIeee || ''
  ]);
  return res.rows[0];
};

const findByUserId = async (userId) => {
  const res = await db.query('SELECT * FROM papers WHERE user_id = $1 ORDER BY created_at DESC', [userId]);
  return res.rows;
};

const findById = async (id) => {
  const res = await db.query('SELECT * FROM papers WHERE id = $1', [id]);
  return res.rows[0];
};

const update = async (id, updateData) => {
  const queryText = `
    UPDATE papers
    SET 
      status = $1,
      processing_stage = $2,
      summary = $3,
      topics = $4,
      content = $5,
      citation_apa = $6,
      citation_mla = $7,
      citation_ieee = $8
    WHERE id = $9
    RETURNING *;
  `;
  const res = await db.query(queryText, [
    updateData.status,
    updateData.processingStage,
    updateData.summary,
    updateData.topics,
    updateData.content,
    updateData.citationApa,
    updateData.citationMla,
    updateData.citationIeee,
    id
  ]);
  return res.rows[0];
};

module.exports = {
  createPaperTable,
  create,
  findByUserId,
  findById,
  update
};
