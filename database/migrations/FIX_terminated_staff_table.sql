-- CRITICAL FIX: Create terminated_staff table if it doesn't exist
-- Run this directly on your Render PostgreSQL database

-- 1. Create terminated_staff table
CREATE TABLE IF NOT EXISTS terminated_staff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Staff information (denormalized for historical record)
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    employee_id VARCHAR(50),
    role_name VARCHAR(100),
    department_name VARCHAR(100),
    branch_name VARCHAR(100),
    
    -- Termination details
    termination_type VARCHAR(50) NOT NULL,
    termination_reason TEXT NOT NULL,
    termination_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Who performed the action
    terminated_by UUID NOT NULL REFERENCES users(id),
    terminated_by_name VARCHAR(255) NOT NULL,
    terminated_by_role VARCHAR(100) NOT NULL,
    
    -- Additional information
    last_working_day DATE,
    final_salary DECIMAL(10, 2),
    clearance_status VARCHAR(50) DEFAULT 'pending',
    clearance_notes TEXT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create indexes
CREATE INDEX IF NOT EXISTS idx_terminated_staff_user_id ON terminated_staff(user_id);
CREATE INDEX IF NOT EXISTS idx_terminated_staff_termination_date ON terminated_staff(termination_date);
CREATE INDEX IF NOT EXISTS idx_terminated_staff_termination_type ON terminated_staff(termination_type);
CREATE INDEX IF NOT EXISTS idx_terminated_staff_department ON terminated_staff(department_name);
CREATE INDEX IF NOT EXISTS idx_terminated_staff_branch ON terminated_staff(branch_name);

-- 3. Ensure is_terminated column exists in users table
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'is_terminated'
    ) THEN
        ALTER TABLE users ADD COLUMN is_terminated BOOLEAN DEFAULT false;
    END IF;
END $$;

-- 4. Create index on is_terminated
CREATE INDEX IF NOT EXISTS idx_users_is_terminated ON users(is_terminated);

-- 5. Verify table was created
SELECT 'terminated_staff table created successfully!' as status;
SELECT COUNT(*) as terminated_staff_count FROM terminated_staff;
