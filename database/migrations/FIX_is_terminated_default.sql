-- Fix is_terminated column to have default value of false
-- This ensures all existing staff are marked as active (not terminated)
-- Run this on your Render PostgreSQL database

-- 1. Add default value to is_terminated column if it doesn't have one
ALTER TABLE users 
ALTER COLUMN is_terminated SET DEFAULT false;

-- 2. Update all NULL values to false (mark existing staff as active)
UPDATE users 
SET is_terminated = false 
WHERE is_terminated IS NULL;

-- 3. Make the column NOT NULL to prevent future NULL values
ALTER TABLE users 
ALTER COLUMN is_terminated SET NOT NULL;

-- 4. Verify the fix
SELECT 
    COUNT(*) FILTER (WHERE is_terminated = true) as terminated_count,
    COUNT(*) FILTER (WHERE is_terminated = false) as active_count,
    COUNT(*) as total_count
FROM users;

-- Expected result: All existing staff should show as active (is_terminated = false)
-- Only staff that were explicitly terminated should have is_terminated = true
