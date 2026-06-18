const db = require('../config/db');

const createUserTable = async () => {
  const queryText = `
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      full_name VARCHAR(100) NOT NULL,
      email VARCHAR(100) UNIQUE NOT NULL,
      password_hash VARCHAR(255) NOT NULL,
      is_verified BOOLEAN DEFAULT FALSE,
      verification_token VARCHAR(255),
      reset_token VARCHAR(255),
      reset_token_expires TIMESTAMP,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;
  try {
    await db.query(queryText);
    console.log("Users table verified/created successfully.");
    
    // Sync existing users to Prisma "User" table
    try {
      await db.query(`
        INSERT INTO "User" (id, "fullName", email, "passwordHash", "isVerified", "verificationToken", "createdAt", "updatedAt")
        SELECT id, full_name, email, password_hash, is_verified, verification_token, created_at, updated_at
        FROM users
        ON CONFLICT (id) DO NOTHING;
      `);
      console.log("Existing users synced to Prisma User table successfully.");
    } catch (syncErr) {
      console.error("Warning: Failed to sync existing users to Prisma:", syncErr.message);
    }
  } catch (err) {
    console.error("Error creating users table:", err.message);
    throw err;
  }
};

const findByEmail = async (email) => {
  const res = await db.query('SELECT * FROM users WHERE email = $1', [email.toLowerCase().trim()]);
  return res.rows[0];
};

const findById = async (id) => {
  const res = await db.query('SELECT id, full_name, email, is_verified, created_at FROM users WHERE id = $1', [id]);
  return res.rows[0];
};

const create = async (fullName, email, passwordHash, verificationToken) => {
  const queryText = `
    INSERT INTO users (full_name, email, password_hash, verification_token)
    VALUES ($1, $2, $3, $4)
    RETURNING id, full_name, email, is_verified, created_at;
  `;
  const res = await db.query(queryText, [
    fullName.trim(),
    email.toLowerCase().trim(),
    passwordHash,
    verificationToken
  ]);
  const user = res.rows[0];

  // Sync to Prisma "User" table
  if (user) {
    try {
      await db.query(`
        INSERT INTO "User" (id, "fullName", email, "passwordHash", "isVerified", "verificationToken", "createdAt", "updatedAt")
        VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
        ON CONFLICT (id) DO UPDATE SET
          "fullName" = EXCLUDED."fullName",
          email = EXCLUDED.email,
          "passwordHash" = EXCLUDED."passwordHash",
          "isVerified" = EXCLUDED."isVerified",
          "verificationToken" = EXCLUDED."verificationToken",
          "updatedAt" = NOW();
      `, [user.id, fullName.trim(), email.toLowerCase().trim(), passwordHash, false, verificationToken]);
    } catch (err) {
      console.error('Failed to sync user to Prisma User table:', err.message);
    }
  }

  return user;
};

const verifyEmail = async (token) => {
  const queryText = `
    UPDATE users
    SET is_verified = TRUE, verification_token = NULL
    WHERE verification_token = $1
    RETURNING id, full_name, email;
  `;
  const res = await db.query(queryText, [token]);
  const user = res.rows[0];

  if (user) {
    try {
      await db.query(`
        UPDATE "User"
        SET "isVerified" = TRUE, "verificationToken" = NULL, "updatedAt" = NOW()
        WHERE id = $1;
      `, [user.id]);
    } catch (err) {
      console.error('Failed to sync verifyEmail to Prisma User table:', err.message);
    }
  }

  return user;
};

const setResetToken = async (email, token, expires) => {
  const queryText = `
    UPDATE users
    SET reset_token = $1, reset_token_expires = $2
    WHERE email = $3
    RETURNING id;
  `;
  const res = await db.query(queryText, [token, expires, email.toLowerCase().trim()]);
  const user = res.rows[0];

  if (user) {
    try {
      await db.query(`
        UPDATE "User"
        SET "resetToken" = $1, "resetTokenExpires" = $2, "updatedAt" = NOW()
        WHERE id = $3;
      `, [token, expires, user.id]);
    } catch (err) {
      console.error('Failed to sync setResetToken to Prisma User table:', err.message);
    }
  }

  return user;
};

const findByResetToken = async (token) => {
  const queryText = `
    SELECT * FROM users
    WHERE reset_token = $1 AND reset_token_expires > CURRENT_TIMESTAMP;
  `;
  const res = await db.query(queryText, [token]);
  return res.rows[0];
};

const updatePassword = async (id, passwordHash) => {
  const queryText = `
    UPDATE users
    SET password_hash = $1, reset_token = NULL, reset_token_expires = NULL
    WHERE id = $2
    RETURNING id;
  `;
  const res = await db.query(queryText, [passwordHash, id]);
  const user = res.rows[0];

  if (user) {
    try {
      await db.query(`
        UPDATE "User"
        SET "passwordHash" = $1, "resetToken" = NULL, "resetTokenExpires" = NULL, "updatedAt" = NOW()
        WHERE id = $2;
      `, [passwordHash, id]);
    } catch (err) {
      console.error('Failed to sync updatePassword to Prisma User table:', err.message);
    }
  }

  return user;
};

module.exports = {
  createUserTable,
  findByEmail,
  findById,
  create,
  verifyEmail,
  setResetToken,
  findByResetToken,
  updatePassword
};
