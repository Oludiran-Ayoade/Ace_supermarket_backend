-- Migration: Add role_id and branch_id to work_experience table
-- This allows tracking Ace Mall roles and branches for internal work experience

-- Add role_id column (nullable for external companies)
ALTER TABLE work_experience 
ADD COLUMN IF NOT EXISTS role_id UUID REFERENCES roles(id);

-- Add branch_id column (nullable for external companies)
ALTER TABLE work_experience 
ADD COLUMN IF NOT EXISTS branch_id UUID REFERENCES branches(id);

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_work_experience_role_id ON work_experience(role_id);
CREATE INDEX IF NOT EXISTS idx_work_experience_branch_id ON work_experience(branch_id);

-- Add comment
COMMENT ON COLUMN work_experience.role_id IS 'Role ID if this is an Ace Mall position (internal work experience)';
COMMENT ON COLUMN work_experience.branch_id IS 'Branch ID if this is an Ace Mall position (internal work experience)';
