const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
require('dotenv').config();

// Helper to sign JWT
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '24h'
  });
};

// @desc    Register a new user
// @route   POST /api/auth/signup
// @access  Public
const signup = async (req, res) => {
  const { fullName, email, password } = req.body;

  if (!fullName || !email || !password) {
    return res.status(400).json({ message: 'Please provide all fields' });
  }

  if (password.length < 6) {
    return res.status(400).json({ message: 'Password must be at least 6 characters long' });
  }

  try {
    // Check if user exists
    const userExists = await User.findByEmail(email);
    if (userExists) {
      return res.status(400).json({ message: 'User already exists with this email' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Generate verification token
    const verificationToken = crypto.randomBytes(32).toString('hex');

    // Create user
    const user = await User.create(fullName, email, passwordHash, verificationToken);

    // Construct verification link
    // Supporting local testing on both mobile emulator and web
    const verificationLink = `http://localhost:3000/api/auth/verify-email?token=${verificationToken}`;
    
    console.log('\n==================================================');
    console.log('✉️  EMAIL VERIFICATION SIMULATOR');
    console.log(`To: ${email}`);
    console.log(`Subject: Verify your Research AI Account`);
    console.log(`Click this link to verify: ${verificationLink}`);
    console.log('==================================================\n');

    res.status(201).json({
      message: 'Registration successful! Please verify your email.',
      user: {
        id: user.id,
        fullName: user.full_name,
        email: user.email,
        isVerified: user.is_verified
      },
      // Return verificationToken in response for testing convenience
      verificationToken
    });
  } catch (err) {
    console.error('Signup error:', err.message);
    res.status(500).json({ message: 'Server error, failed to register user' });
  }
};

// @desc    Authenticate user & get token
// @route   POST /api/auth/login
// @access  Public
const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Please provide email and password' });
  }

  try {
    // Check for user
    const user = await User.findByEmail(email);

    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Check password
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Check verification
    if (!user.is_verified) {
      return res.status(403).json({
        message: 'Please verify your email before logging in.',
        isVerified: false,
        verificationToken: user.verification_token
      });
    }

    // Generate token
    const token = generateToken(user.id);

    res.json({
      token,
      user: {
        id: user.id,
        fullName: user.full_name,
        email: user.email,
        isVerified: user.is_verified
      }
    });
  } catch (err) {
    console.error('Login error:', err.message);
    res.status(500).json({ message: 'Server error, login failed' });
  }
};

// @desc    Verify email address
// @route   GET or POST /api/auth/verify-email
// @access  Public
const verifyEmail = async (req, res) => {
  // Support both GET query (?token=...) and POST body ({ token: ... })
  const token = req.query.token || req.body.token;

  if (!token) {
    return res.status(400).json({ message: 'Verification token is required' });
  }

  try {
    const user = await User.verifyEmail(token);

    if (!user) {
      if (req.method === 'GET') {
        return res.send(`
          <html>
            <body style="font-family: sans-serif; text-align: center; padding: 50px; background: #F8F9FA;">
              <div style="max-width: 400px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                <h1 style="color: #DC3545;">Verification Failed</h1>
                <p>The verification link is invalid or has already been used.</p>
              </div>
            </body>
          </html>
        `);
      }
      return res.status(400).json({ message: 'Invalid or expired verification token' });
    }

    if (req.method === 'GET') {
      return res.send(`
        <html>
          <body style="font-family: sans-serif; text-align: center; padding: 50px; background: #F8F9FA;">
            <div style="max-width: 400px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
              <h1 style="color: #6200EE;">Email Verified!</h1>
              <p>Hi ${user.full_name}, your email (${user.email}) has been successfully verified.</p>
              <p>You can now return to the Research AI app and log in.</p>
            </div>
          </body>
        </html>
      `);
    }

    res.json({
      message: 'Email successfully verified!',
      user: {
        id: user.id,
        fullName: user.full_name,
        email: user.email,
        isVerified: true
      }
    });
  } catch (err) {
    console.error('Email verification error:', err.message);
    res.status(500).json({ message: 'Server error during email verification' });
  }
};

// @desc    Forgot Password
// @route   POST /api/auth/forgot-password
// @access  Public
const forgotPassword = async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Email is required' });
  }

  try {
    const user = await User.findByEmail(email);
    if (!user) {
      return res.status(404).json({ message: 'No account found with this email' });
    }

    // Generate reset token and expiration (1 hour)
    const resetToken = crypto.randomBytes(32).toString('hex');
    const expires = new Date(Date.now() + 3600000); // 1 hour from now

    await User.setResetToken(email, resetToken, expires);

    // Construct reset link
    const resetLink = `http://localhost:3000/api/auth/reset-password?token=${resetToken}`;

    console.log('\n==================================================');
    console.log('🔑  PASSWORD RESET SIMULATOR');
    console.log(`To: ${email}`);
    console.log(`Subject: Reset your Research AI Password`);
    console.log(`Click this link to reset password: ${resetLink}`);
    console.log('==================================================\n');

    res.json({
      message: 'Password reset link generated. Check logs or response.',
      resetToken // Return in response for testing convenience
    });
  } catch (err) {
    console.error('Forgot password error:', err.message);
    res.status(500).json({ message: 'Server error during forgot password' });
  }
};

// @desc    Reset Password
// @route   POST /api/auth/reset-password
// @access  Public
const resetPassword = async (req, res) => {
  const { token, password } = req.body;

  if (!token || !password) {
    return res.status(400).json({ message: 'Token and new password are required' });
  }

  if (password.length < 6) {
    return res.status(400).json({ message: 'Password must be at least 6 characters long' });
  }

  try {
    // Find user with valid token
    const user = await User.findByResetToken(token);
    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired password reset token' });
    }

    // Hash new password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Update password
    await User.updatePassword(user.id, passwordHash);

    res.json({ message: 'Password has been reset successfully! You can now log in.' });
  } catch (err) {
    console.error('Reset password error:', err.message);
    res.status(500).json({ message: 'Server error during password reset' });
  }
};

// @desc    Get Current User Profile
// @route   GET /api/auth/me
// @access  Private
const getMe = async (req, res) => {
  res.json({ user: req.user });
};

module.exports = {
  signup,
  login,
  verifyEmail,
  forgotPassword,
  resetPassword,
  getMe
};
