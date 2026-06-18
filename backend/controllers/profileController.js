const Profile = require('../models/profileModel');

// @desc    Upsert user profile details
// @route   POST /api/profile
// @access  Private
const upsertProfile = async (req, res) => {
  const { academicLevel, interests, avatarUrl } = req.body;
  const userId = req.user.id;

  if (!academicLevel || !interests || !Array.isArray(interests)) {
    return res.status(400).json({ message: 'Academic level and research interests are required.' });
  }

  try {
    const profile = await Profile.upsert(userId, academicLevel, interests, avatarUrl);
    res.status(200).json({
      message: 'Profile updated successfully!',
      profile: {
        userId: profile.user_id,
        academicLevel: profile.academic_level,
        interests: profile.interests,
        avatarUrl: profile.avatar_url,
        updatedAt: profile.updated_at
      }
    });
  } catch (err) {
    console.error('Upsert profile error:', err.message);
    res.status(500).json({ message: 'Server error, failed to save profile.' });
  }
};

// @desc    Get user profile details
// @route   GET /api/profile
// @access  Private
const getProfile = async (req, res) => {
  const userId = req.user.id;

  try {
    const profile = await Profile.findByUserId(userId);
    if (!profile) {
      return res.status(404).json({
        message: 'No profile found for this user.',
        needsSetup: true
      });
    }

    res.json({
      profile: {
        userId: profile.user_id,
        academicLevel: profile.academic_level,
        interests: profile.interests,
        avatarUrl: profile.avatar_url
      }
    });
  } catch (err) {
    console.error('Get profile error:', err.message);
    res.status(500).json({ message: 'Server error, failed to retrieve profile.' });
  }
};

module.exports = {
  upsertProfile,
  getProfile
};
