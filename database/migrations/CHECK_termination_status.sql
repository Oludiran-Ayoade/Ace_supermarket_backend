-- Run this to check if termination is working
-- Copy the output and share with me

-- 1. Check if any staff are marked as terminated
SELECT 
    id, 
    full_name, 
    email, 
    is_active, 
    is_terminated,
    updated_at
FROM users 
WHERE is_terminated = true
ORDER BY updated_at DESC
LIMIT 5;

-- 2. Check terminated_staff table
SELECT 
    id,
    full_name,
    email,
    termination_type,
    termination_reason,
    termination_date,
    terminated_by_name
FROM terminated_staff
ORDER BY termination_date DESC
LIMIT 5;

-- 3. Count active vs terminated staff
SELECT 
    COUNT(*) FILTER (WHERE is_active = true AND is_terminated = false) as active_staff,
    COUNT(*) FILTER (WHERE is_terminated = true) as terminated_staff,
    COUNT(*) as total_staff
FROM users;

-- 4. Check if is_terminated column exists and has correct type
SELECT 
    column_name, 
    data_type, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name IN ('is_active', 'is_terminated');
