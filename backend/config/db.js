const { Pool } = require('pg');
require('dotenv').config();

const cleanConnectionString = process.env.DATABASE_URL ? process.env.DATABASE_URL.split('?')[0] : '';

const pool = new Pool({
  connectionString: cleanConnectionString,
  ssl: process.env.DATABASE_URL && (process.env.DATABASE_URL.includes('supabase') || process.env.DATABASE_URL.includes('sslmode='))
    ? { rejectUnauthorized: false }
    : false
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