-- Add date_joined column to terminated_staff table
-- Run this on your Render PostgreSQL database

-- Add date_joined column
ALTER TABLE terminated_staff 
ADD COLUMN IF NOT EXISTS date_joined DATE;

-- Update existing records with date_joined from users table
UPDATE terminated_staff ts
SET date_joined = u.date_joined
FROM users u
WHERE ts.user_id = u.id
AND ts.date_joined IS NULL;

-- Verify column was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'terminated_staff' 
AND column_name = 'date_joined';
