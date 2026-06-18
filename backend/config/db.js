const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const initDatabase = async () => {
  try {
    const client = await pool.connect();
    console.log('✅ PostgreSQL connected successfully');
    client.release();
  } catch (err) {
    console.error('❌ Database connection failed:', err.message);
    throw err;
  }
};

module.exports = {
  query: (text, params) => pool.query(text, params),
  initDatabase,
};