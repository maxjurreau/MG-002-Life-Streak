-- 08_SCHEMA.sql: Cloudflare D1 Relational Schema for MG-002 Life Streak

CREATE TABLE IF NOT EXISTS users (
    user_id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS habits (
    habit_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL, -- e.g., 'Focus', 'Fitness', 'Learning'
    current_streak INTEGER NOT NULL DEFAULT 0,
    longest_streak INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS streak_logs (
    log_id TEXT PRIMARY KEY,
    habit_id TEXT NOT NULL,
    completion_date DATE NOT NULL,
    status BOOLEAN NOT NULL DEFAULT 1,
    FOREIGN KEY (habit_id) REFERENCES habits(habit_id)
);

-- Index for high-performance streak queries at the edge
CREATE INDEX IF NOT EXISTS idx_habits_user ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_logs_habit ON streak_logs(habit_id, completion_date);
