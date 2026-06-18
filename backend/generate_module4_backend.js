const fs = require('fs');
const path = require('path');

const dbPath = path.join(__dirname, 'config', 'db.js');
let dbContent = fs.readFileSync(dbPath, 'utf-8');

if (!dbContent.includes('const mockNotifications = [];')) {
  const mockDeclarations = `
const mockNotifications = [];
let mockNotificationIdCounter = 1;

const mockSettings = [];
let mockSettingsIdCounter = 1;

const mockSupportTickets = [];
let mockTicketIdCounter = 1;

const mockFeedback = [];
let mockFeedbackIdCounter = 1;
`;
  dbContent = dbContent.replace(
    'const mockChatMessages = [];',
    mockDeclarations + '\nconst mockChatMessages = [];'
  );
}

const newMockHandlers = `
  // MODULE 4: NOTIFICATIONS SELECT
  if (normalizedText.includes('SELECT * FROM notifications WHERE user_id = $1')) {
    const userId = parseInt(params[0]);
    return { rows: mockNotifications.filter(n => n.user_id === userId) };
  }

  // MODULE 4: NOTIFICATIONS UPDATE READ
  if (normalizedText.includes('UPDATE notifications SET is_read = TRUE WHERE id = $1')) {
    const nId = parseInt(params[0]);
    const notif = mockNotifications.find(n => n.id === nId);
    if (notif) notif.is_read = true;
    return { rows: notif ? [notif] : [] };
  }

  // MODULE 4: NOTIFICATIONS INSERT (For tests)
  if (normalizedText.includes('INSERT INTO notifications')) {
    const notif = {
      id: mockNotificationIdCounter++,
      user_id: parseInt(params[0]),
      title: params[1],
      message: params[2],
      is_read: false,
      created_at: new Date()
    };
    mockNotifications.push(notif);
    return { rows: [notif] };
  }

  // MODULE 4: SETTINGS SELECT
  if (normalizedText.includes('SELECT * FROM settings WHERE user_id = $1')) {
    const userId = parseInt(params[0]);
    let setting = mockSettings.find(s => s.user_id === userId);
    if (!setting) {
      setting = { id: mockSettingsIdCounter++, user_id: userId, dark_mode: false, ai_model: 'default', privacy_telemetry: true };
      mockSettings.push(setting);
    }
    return { rows: [setting] };
  }

  // MODULE 4: SETTINGS UPDATE
  if (normalizedText.includes('UPDATE settings SET dark_mode = $1, ai_model = $2, privacy_telemetry = $3 WHERE user_id = $4')) {
    const userId = parseInt(params[3]);
    let setting = mockSettings.find(s => s.user_id === userId);
    if (setting) {
      setting.dark_mode = params[0];
      setting.ai_model = params[1];
      setting.privacy_telemetry = params[2];
    } else {
      setting = { id: mockSettingsIdCounter++, user_id: userId, dark_mode: params[0], ai_model: params[1], privacy_telemetry: params[2] };
      mockSettings.push(setting);
    }
    return { rows: [setting] };
  }

  // MODULE 4: SUPPORT INSERT
  if (normalizedText.includes('INSERT INTO support_tickets')) {
    const ticket = {
      id: mockTicketIdCounter++,
      user_id: parseInt(params[0]),
      subject: params[1],
      description: params[2],
      status: 'open',
      created_at: new Date()
    };
    mockSupportTickets.push(ticket);
    return { rows: [ticket] };
  }

  // MODULE 4: FEEDBACK INSERT
  if (normalizedText.includes('INSERT INTO feedback')) {
    const feedback = {
      id: mockFeedbackIdCounter++,
      user_id: parseInt(params[0]),
      rating: parseInt(params[1]),
      comment: params[2],
      created_at: new Date()
    };
    mockFeedback.push(feedback);
    return { rows: [feedback] };
  }
`;

if (!dbContent.includes('MODULE 4: NOTIFICATIONS SELECT')) {
  dbContent = dbContent.replace(
    'console.warn(`⚠️ Unhandled mock query:',
    newMockHandlers + '\n  console.warn(`⚠️ Unhandled mock query:'
  );
  fs.writeFileSync(dbPath, dbContent);
}

// ---------------------------------------------------------
// Generate Controllers
// ---------------------------------------------------------
const controllers = {
  'notificationController.js': `
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
`,
  'settingsController.js': `
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
`,
  'supportController.js': `
const db = require('../config/db');

exports.submitContact = async (req, res) => {
  try {
    const userId = req.user.id;
    const { subject, description } = req.body;
    const result = await db.query(
      'INSERT INTO support_tickets (user_id, subject, description) VALUES ($1, $2, $3) RETURNING *',
      [userId, subject, description]
    );
    res.json({ success: true, ticket: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.submitFeedback = async (req, res) => {
  try {
    const userId = req.user.id;
    const { rating, comment } = req.body;
    const result = await db.query(
      'INSERT INTO feedback (user_id, rating, comment) VALUES ($1, $2, $3) RETURNING *',
      [userId, rating, comment]
    );
    res.json({ success: true, feedback: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
`
};

Object.entries(controllers).forEach(([file, content]) => {
  fs.writeFileSync(path.join(__dirname, 'controllers', file), content.trim());
});

// ---------------------------------------------------------
// Generate Routes
// ---------------------------------------------------------
const routes = {
  'notificationRoutes.js': `
const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, notificationController.getNotifications);
router.post('/:id/read', authMiddleware, notificationController.markRead);

module.exports = router;
`,
  'settingsRoutes.js': `
const express = require('express');
const router = express.Router();
const settingsController = require('../controllers/settingsController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, settingsController.getSettings);
router.put('/', authMiddleware, settingsController.updateSettings);

module.exports = router;
`,
  'supportRoutes.js': `
const express = require('express');
const router = express.Router();
const supportController = require('../controllers/supportController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/contact', authMiddleware, supportController.submitContact);
router.post('/feedback', authMiddleware, supportController.submitFeedback);

module.exports = router;
`
};

Object.entries(routes).forEach(([file, content]) => {
  fs.writeFileSync(path.join(__dirname, 'routes', file), content.trim());
});

// ---------------------------------------------------------
// Update server.js
// ---------------------------------------------------------
const serverPath = path.join(__dirname, 'server.js');
let serverContent = fs.readFileSync(serverPath, 'utf-8');

if (!serverContent.includes('./routes/notificationRoutes')) {
  serverContent = serverContent.replace(
    "const citationRoutes = require('./routes/citationRoutes');",
    `const citationRoutes = require('./routes/citationRoutes');\nconst notificationRoutes = require('./routes/notificationRoutes');\nconst settingsRoutes = require('./routes/settingsRoutes');\nconst supportRoutes = require('./routes/supportRoutes');`
  );

  serverContent = serverContent.replace(
    "app.use('/api/citations', citationRoutes);",
    `app.use('/api/citations', citationRoutes);\napp.use('/api/notifications', notificationRoutes);\napp.use('/api/settings', settingsRoutes);\napp.use('/api/support', supportRoutes);`
  );
  
  fs.writeFileSync(serverPath, serverContent);
}

console.log('Module 4 backend files generated successfully.');
