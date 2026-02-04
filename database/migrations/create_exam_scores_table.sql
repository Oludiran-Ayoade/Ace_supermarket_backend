-- Create exam_scores table
CREATE TABLE IF NOT EXISTS exam_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    exam_type VARCHAR(100) NOT NULL DEFAULT 'General',
    score VARCHAR(255),
    year_taken INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_exam_scores_user_id ON exam_scores(user_id);

-- Add comment
COMMENT ON TABLE exam_scores IS 'Stores exam scores (WAEC, NECO, JAMB, etc.) for staff members';
