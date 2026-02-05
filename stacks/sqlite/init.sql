-- Initialize database for Terraform Workshop
-- This script creates the initial database schema

-- Create visitors table
CREATE TABLE IF NOT EXISTS visitors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create sample data
INSERT INTO visitors (name, visit_time) VALUES
    ('Alice Workshop', datetime('now', '-2 days')),
    ('Bob Terraform', datetime('now', '-1 day')),
    ('Charlie Docker', datetime('now', '-12 hours'));

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_visit_time ON visitors(visit_time DESC);

-- Application settings table
CREATE TABLE IF NOT EXISTS app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default settings
INSERT OR IGNORE INTO app_settings (key, value) VALUES
    ('app_name', 'Terraform Workshop'),
    ('version', '1.0.0'),
    ('initialized', datetime('now'));
