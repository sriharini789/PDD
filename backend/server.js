const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { initDatabase } = require('./config/db');
const { createUserTable } = require('./models/userModel');
const { createProfileTable } = require('./models/profileModel');
const { createPaperTable } = require('./models/paperModel');
const { createChatTable } = require('./models/chatModel');

const authRoutes = require('./routes/authRoutes');
const profileRoutes = require('./routes/profileRoutes');
const paperRoutes = require('./routes/paperRoutes');
const chatRoutes = require('./routes/chatRoutes');
const searchRoutes = require('./routes/searchRoutes');
const libraryRoutes = require('./routes/libraryRoutes');
const noteRoutes = require('./routes/noteRoutes');
const citationRoutes = require('./routes/citationRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const settingsRoutes = require('./routes/settingsRoutes');
const supportRoutes = require('./routes/supportRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
// Middleware
app.use(cors({
  origin: true,
  credentials: true,
}));

app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/papers', paperRoutes);
app.use('/api/papers', chatRoutes); // Mounted under papers for restful nesting
const exportRoutes = require('./routes/exportRoutes');
app.use('/api/export', exportRoutes);

// Root Endpoint
app.get('/', (req, res) => {
  res.json({ message: 'Research AI Auth, Profile & Dashboard API is running...' });
});

// Initialization function
const startServer = async () => {
  try {
    // 1. Init Database pool
    await initDatabase();

    // 2. Setup database schemas (in order of dependencies)
    await createUserTable();
    await createProfileTable();
    await createPaperTable();
    await createChatTable();

    // 3. Start Express server
  app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
    });
  } catch (err) {
    console.error('Fatal server startup error:', err.message);
    process.exit(1);
  }
};

startServer();
