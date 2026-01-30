-- Migration: Create work_experience table
-- This table stores previous employment history for staff

CREATE TABLE IF NOT EXISTS work_experience (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    company_name VARCHAR(200) NOT NULL,
    position VARCHAR(200) NOT NULL,
    start_date DATE,
    end_date DATE,
    responsibilities TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster lookups by user_id
CREATE INDEX IF NOT EXISTS idx_work_experience_user_id ON work_experience(user_id);

-- Verify table was created
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'work_experience') THEN
        RAISE NOTICE 'SUCCESS: work_experience table created';
    ELSE
        RAISE EXCEPTION 'FAILED: work_experience table was not created';
    END IF;
END $$;
