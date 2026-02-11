const express = require('express');
const Database = require('better-sqlite3');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Database connection
let db;
const DB_PATH = process.env.DB_PATH || '/data/workshop.db';

function initDatabase() {
  try {
    db = new Database(DB_PATH, { verbose: console.log });
    console.log('✅ Connected to SQLite database at:', DB_PATH);

    // Ensure table exists
    db.exec(`
      CREATE TABLE IF NOT EXISTS visitors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    console.log('✅ Database tables verified');
  } catch (error) {
    console.error('❌ Database connection error:', error);
    process.exit(1);
  }
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    database: db ? 'connected' : 'disconnected'
  });
});

// API: Get all visitors
app.get('/api/visitors', (req, res) => {
  try {
    const visitors = db.prepare('SELECT * FROM visitors ORDER BY visit_time DESC').all();
    res.json({ success: true, data: visitors });
  } catch (error) {
    console.error('Error fetching visitors:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: Add a new visitor
app.post('/api/visitors', (req, res) => {
  const { name } = req.body;

  if (!name || name.trim() === '') {
    return res.status(400).json({ success: false, error: 'Name is required' });
  }

  try {
    const stmt = db.prepare('INSERT INTO visitors (name) VALUES (?)');
    const result = stmt.run(name.trim());

    const newVisitor = db.prepare('SELECT * FROM visitors WHERE id = ?').get(result.lastInsertRowid);

    res.json({ success: true, data: newVisitor });
  } catch (error) {
    console.error('Error adding visitor:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// API: Get visitor count
app.get('/api/stats', (req, res) => {
  try {
    const count = db.prepare('SELECT COUNT(*) as count FROM visitors').get();
    const recent = db.prepare('SELECT * FROM visitors ORDER BY visit_time DESC LIMIT 5').all();

    res.json({
      success: true,
      data: {
        totalVisitors: count.count,
        recentVisitors: recent
      }
    });
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Serve main page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Initialize database and start server
initDatabase();

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
  console.log(`📊 Database: ${DB_PATH}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing database connection...');
  if (db) db.close();
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, closing database connection...');
  if (db) db.close();
  process.exit(0);
});
