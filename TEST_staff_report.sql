-- Test query to check if staff report would return data
-- Run this on your Render PostgreSQL database to debug

-- 1. Check total non-terminated staff
SELECT COUNT(*) as total_active_staff
FROM users 
WHERE is_terminated = false;

-- 2. Check if is_terminated column exists and has correct values
SELECT 
    COUNT(*) FILTER (WHERE is_terminated = true) as terminated_count,
    COUNT(*) FILTER (WHERE is_terminated = false) as active_count,
    COUNT(*) FILTER (WHERE is_terminated IS NULL) as null_count,
    COUNT(*) as total_count
FROM users;

-- 3. Test the exact query from staff_reports.go
SELECT 
    u.id, u.full_name, u.gender, u.date_of_birth, u.date_joined,
    u.course_of_study, u.grade, u.institution, u.exam_scores,
    u.current_salary, u.employee_id,
    r.name as role_name, r.category as role_category,
    d.name as department_name,
    b.name as branch_name
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
LEFT JOIN departments d ON u.department_id = d.id
LEFT JOIN branches b ON u.branch_id = b.id
WHERE u.is_terminated = false
ORDER BY u.date_joined ASC
LIMIT 5;

-- 4. If above returns 0, check if is_terminated column has default value
SELECT column_name, column_default, is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name = 'is_terminated';
