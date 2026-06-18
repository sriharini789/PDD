const db = require('../config/db');

const createProfileTable = async () => {
  const queryText = `
    CREATE TABLE IF NOT EXISTS profiles (
      user_id INT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
      academic_level VARCHAR(50) NOT NULL,
      interests TEXT[] NOT NULL,
      avatar_url VARCHAR(255),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;
  try {
    await db.query(queryText);
    console.log("Profiles table verified/created successfully.");

    // Sync existing profiles to Prisma "Profile" table
    try {
      await db.query(`
        INSERT INTO "Profile" ("userId", "academicLevel", interests, "avatarUrl", "createdAt", "updatedAt")
        SELECT user_id, academic_level, interests, avatar_url, created_at, updated_at
        FROM profiles
        ON CONFLICT ("userId") DO NOTHING;
      `);
      console.log("Existing profiles synced to Prisma Profile table successfully.");
    } catch (syncErr) {
      console.error("Warning: Failed to sync existing profiles to Prisma:", syncErr.message);
    }
  } catch (err) {
    console.error("Error creating profiles table:", err.message);
    throw err;
  }
};

const findByUserId = async (userId) => {
  const res = await db.query('SELECT * FROM profiles WHERE user_id = $1', [userId]);
  return res.rows[0];
};

const upsert = async (userId, academicLevel, interests, avatarUrl = null) => {
  const queryText = `
    INSERT INTO profiles (user_id, academic_level, interests, avatar_url, updated_at)
    VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
    ON CONFLICT (user_id)
    DO UPDATE SET 
      academic_level = EXCLUDED.academic_level,
      interests = EXCLUDED.interests,
      avatar_url = EXCLUDED.avatar_url,
      updated_at = CURRENT_TIMESTAMP
    RETURNING *;
  `;
  const res = await db.query(queryText, [userId, academicLevel, interests, avatarUrl]);
  const profile = res.rows[0];

  if (profile) {
    try {
      await db.query(`
        INSERT INTO "Profile" ("userId", "academicLevel", interests, "avatarUrl", "createdAt", "updatedAt")
        VALUES ($1, $2, $3, $4, NOW(), NOW())
        ON CONFLICT ("userId")
        DO UPDATE SET
          "academicLevel" = EXCLUDED."academicLevel",
          interests = EXCLUDED.interests,
          "avatarUrl" = EXCLUDED."avatarUrl",
          "updatedAt" = NOW();
      `, [userId, academicLevel, interests, avatarUrl]);
    } catch (err) {
      console.error('Failed to sync profile to Prisma Profile table:', err.message);
    }
  }

  return profile;
};

module.exports = {
  createProfileTable,
  findByUserId,
  upsert
};
