-- Create role_history table for tracking roles held at Ace Mall
-- Run this on your production database

CREATE TABLE IF NOT EXISTS role_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID REFERENCES roles(id),
    department_id UUID REFERENCES departments(id),
    branch_id UUID REFERENCES branches(id),
    start_date DATE NOT NULL,
    end_date DATE,
    promotion_reason TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_role_history_user ON role_history(user_id);
CREATE INDEX IF NOT EXISTS idx_role_history_dates ON role_history(start_date, end_date);

-- Verify table was created
SELECT 'role_history table created successfully!' AS message;
