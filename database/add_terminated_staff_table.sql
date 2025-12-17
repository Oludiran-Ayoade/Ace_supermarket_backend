-- Migration: Add terminated/departed staff tracking system
-- This table stores staff who have been terminated or left the organization

-- Create terminated_staff table
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
    termination_type VARCHAR(50) NOT NULL, -- 'terminated', 'resigned', 'retired', 'contract_ended'
    termination_reason TEXT NOT NULL,
    termination_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Who performed the action
    terminated_by UUID NOT NULL REFERENCES users(id),
    terminated_by_name VARCHAR(255) NOT NULL,
    terminated_by_role VARCHAR(100) NOT NULL,
    
    -- Additional information
    last_working_day DATE,
    final_salary DECIMAL(10, 2),
    clearance_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'cleared', 'issues'
    clearance_notes TEXT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX idx_terminated_staff_user_id ON terminated_staff(user_id);
CREATE INDEX idx_terminated_staff_termination_date ON terminated_staff(termination_date);
CREATE INDEX idx_terminated_staff_termination_type ON terminated_staff(termination_type);
CREATE INDEX idx_terminated_staff_department ON terminated_staff(department_name);
CREATE INDEX idx_terminated_staff_branch ON terminated_staff(branch_name);

-- Add is_active column to users table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'is_active'
    ) THEN
        ALTER TABLE users ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;
END $$;

-- Create index on is_active for filtering
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_terminated_staff_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_terminated_staff_updated_at
    BEFORE UPDATE ON terminated_staff
    FOR EACH ROW
    EXECUTE FUNCTION update_terminated_staff_updated_at();

-- Create view for easy access to terminated staff with full details
CREATE OR REPLACE VIEW v_terminated_staff_details AS
SELECT 
    ts.*,
    u.phone,
    u.date_of_birth,
    u.gender,
    u.address,
    u.date_joined,
    EXTRACT(YEAR FROM AGE(ts.termination_date, u.date_joined)) AS years_of_service,
    EXTRACT(MONTH FROM AGE(ts.termination_date, u.date_joined)) AS months_of_service
FROM terminated_staff ts
LEFT JOIN users u ON ts.user_id = u.id
ORDER BY ts.termination_date DESC;

COMMENT ON TABLE terminated_staff IS 'Archive of terminated or departed staff members';
COMMENT ON COLUMN terminated_staff.termination_type IS 'Type of departure: terminated, resigned, retired, contract_ended';
COMMENT ON COLUMN terminated_staff.clearance_status IS 'Exit clearance status: pending, cleared, issues';
