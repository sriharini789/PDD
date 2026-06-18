const fs = require('fs');
const path = require('path');

const dbPath = path.join(__dirname, 'config', 'db.js');
let dbContent = fs.readFileSync(dbPath, 'utf-8');

if (!dbContent.includes('const mockNotes = [];')) {
  dbContent = dbContent.replace(
    'const mockChatMessages = [];',
    'const mockNotes = [];\nlet mockNoteIdCounter = 1;\n\nconst mockReadingLists = [];\nlet mockReadingListIdCounter = 1;\n\nconst mockChatMessages = [];'
  );
}

// Ensure papers table logic accommodates new columns.
// Add some mock handlers for Module 3 if they don't exist
const newMockHandlers = `
  // MODULE 3: NOTES INSERT
  if (normalizedText.includes('INSERT INTO notes')) {
    const newNote = {
      id: mockNoteIdCounter++,
      paper_id: parseInt(params[0]),
      user_id: parseInt(params[1]),
      content: params[2],
      highlighted_text: params[3],
      page_number: params[4],
      created_at: new Date()
    };
    mockNotes.push(newNote);
    return { rows: [newNote] };
  }

  // MODULE 3: NOTES SELECT
  if (normalizedText.includes('SELECT * FROM notes WHERE paper_id = $1')) {
    const paperId = parseInt(params[0]);
    const notes = mockNotes.filter(n => n.paper_id === paperId);
    return { rows: notes };
  }

  // MODULE 3: READING LISTS INSERT
  if (normalizedText.includes('INSERT INTO reading_lists')) {
    const newList = {
      id: mockReadingListIdCounter++,
      user_id: parseInt(params[0]),
      name: params[1],
      created_at: new Date()
    };
    mockReadingLists.push(newList);
    return { rows: [newList] };
  }

  // MODULE 3: READING LISTS SELECT
  if (normalizedText.includes('SELECT * FROM reading_lists WHERE user_id = $1')) {
    const userId = parseInt(params[0]);
    const lists = mockReadingLists.filter(l => l.user_id === userId);
    return { rows: lists };
  }

  // MODULE 3: PAPER FAVORITE UPDATE
  if (normalizedText.includes('UPDATE papers SET is_favorite = $1 WHERE id = $2')) {
    const isFav = params[0];
    const pId = parseInt(params[1]);
    const pIndex = mockPapers.findIndex(p => p.id === pId);
    if (pIndex !== -1) {
      mockPapers[pIndex].is_favorite = isFav;
      return { rows: [mockPapers[pIndex]] };
    }
    return { rows: [] };
  }

  // MODULE 3: PAPER SEARCH (Global)
  if (normalizedText.includes('SELECT * FROM papers WHERE title ILIKE')) {
    const query = params[0].replace(/%/g, '').toLowerCase();
    const results = mockPapers.filter(p => p.title.toLowerCase().includes(query) || p.summary.toLowerCase().includes(query));
    return { rows: results };
  }
`;

if (!dbContent.includes('MODULE 3: NOTES INSERT')) {
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
  'searchController.js': `
const db = require('../config/db');

exports.searchPapers = async (req, res) => {
  try {
    const { q } = req.query;
    const result = await db.query('SELECT * FROM papers WHERE title ILIKE $1 OR summary ILIKE $1', [\`%\${q}%\`]);
    res.json({ success: true, results: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.askGlobalQuestion = async (req, res) => {
  try {
    const { question } = req.body;
    // Simulate RAG over multiple papers
    setTimeout(() => {
      res.json({ 
        success: true, 
        answer: "This is an AI generated answer based on multiple sources for: " + question,
        sources: [1, 2] // Mock paper IDs
      });
    }, 1000);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
`,
  'libraryController.js': `
const db = require('../config/db');

exports.getLibrary = async (req, res) => {
  try {
    const userId = req.user.id;
    const papersResult = await db.query('SELECT * FROM papers WHERE user_id = $1', [userId]);
    const listsResult = await db.query('SELECT * FROM reading_lists WHERE user_id = $1', [userId]);
    
    res.json({ 
      success: true, 
      papers: papersResult.rows,
      readingLists: listsResult.rows 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.createReadingList = async (req, res) => {
  try {
    const userId = req.user.id;
    const { name } = req.body;
    const result = await db.query(
      'INSERT INTO reading_lists (user_id, name) VALUES ($1, $2) RETURNING *',
      [userId, name]
    );
    res.json({ success: true, list: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.toggleFavorite = async (req, res) => {
  try {
    const paperId = req.params.id;
    const { is_favorite } = req.body;
    const result = await db.query(
      'UPDATE papers SET is_favorite = $1 WHERE id = $2 RETURNING *',
      [is_favorite, paperId]
    );
    res.json({ success: true, paper: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
`,
  'noteController.js': `
const db = require('../config/db');

exports.getNotes = async (req, res) => {
  try {
    const paperId = req.params.id;
    const result = await db.query('SELECT * FROM notes WHERE paper_id = $1', [paperId]);
    res.json({ success: true, notes: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.addNote = async (req, res) => {
  try {
    const paperId = req.params.id;
    const userId = req.user.id;
    const { content, highlighted_text, page_number } = req.body;
    
    const result = await db.query(
      'INSERT INTO notes (paper_id, user_id, content, highlighted_text, page_number) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [paperId, userId, content, highlighted_text, page_number]
    );
    res.json({ success: true, note: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
`,
  'citationController.js': `
const db = require('../config/db');

exports.getCitations = async (req, res) => {
  try {
    const paperId = req.params.id;
    const result = await db.query('SELECT citation_apa, citation_mla, citation_ieee FROM papers WHERE id = $1', [paperId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Paper not found" });
    }
    res.json({ success: true, citations: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.exportPaper = async (req, res) => {
  try {
    const paperId = req.params.id;
    const { format } = req.body; // e.g., 'pdf', 'bibtex'
    // Simulate export
    res.json({ 
      success: true, 
      downloadUrl: \`https://api.example.com/exports/\${paperId}.\${format}\`
    });
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
  'searchRoutes.js': `
const express = require('express');
const router = express.Router();
const searchController = require('../controllers/searchController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, searchController.searchPapers);
router.post('/ask', authMiddleware, searchController.askGlobalQuestion);

module.exports = router;
`,
  'libraryRoutes.js': `
const express = require('express');
const router = express.Router();
const libraryController = require('../controllers/libraryController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, libraryController.getLibrary);
router.post('/reading-list', authMiddleware, libraryController.createReadingList);
router.post('/papers/:id/favorite', authMiddleware, libraryController.toggleFavorite);

module.exports = router;
`,
  'noteRoutes.js': `
const express = require('express');
const router = express.Router();
const noteController = require('../controllers/noteController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/papers/:id/notes', authMiddleware, noteController.getNotes);
router.post('/papers/:id/notes', authMiddleware, noteController.addNote);

module.exports = router;
`,
  'citationRoutes.js': `
const express = require('express');
const router = express.Router();
const citationController = require('../controllers/citationController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/papers/:id/citations', authMiddleware, citationController.getCitations);
router.post('/papers/:id/export', authMiddleware, citationController.exportPaper);

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

if (!serverContent.includes('./routes/searchRoutes')) {
  serverContent = serverContent.replace(
    "const chatRoutes = require('./routes/chatRoutes');",
    `const chatRoutes = require('./routes/chatRoutes');\nconst searchRoutes = require('./routes/searchRoutes');\nconst libraryRoutes = require('./routes/libraryRoutes');\nconst noteRoutes = require('./routes/noteRoutes');\nconst citationRoutes = require('./routes/citationRoutes');`
  );

  serverContent = serverContent.replace(
    "app.use('/api/chat', chatRoutes);",
    `app.use('/api/chat', chatRoutes);\napp.use('/api/search', searchRoutes);\napp.use('/api/library', libraryRoutes);\napp.use('/api/notes', noteRoutes);\napp.use('/api/citations', citationRoutes);`
  );
  
  fs.writeFileSync(serverPath, serverContent);
}

console.log('Module 3 backend files generated successfully.');
