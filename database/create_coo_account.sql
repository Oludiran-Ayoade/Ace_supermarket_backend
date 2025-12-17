-- Create COO Test Account for Ace Supermarket
-- Password: password (hashed with bcrypt)

-- Insert COO user
INSERT INTO users (
    full_name,
    email,
    password_hash,
    role_id,
    employee_id,
    date_joined,
    is_active
) 
SELECT 
    'Michael Adeyemi',
    'coo@acemarket.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMye7FIrjMZjKcIVkggMKingy5nYEYYGpW6',  -- password: password
    id,
    'COO001',
    CURRENT_DATE - INTERVAL '2 years',
    true
FROM roles 
WHERE name = 'Chief Operating Officer'
LIMIT 1;

-- Verify the account was created
SELECT 
    u.id,
    u.full_name,
    u.email,
    u.employee_id,
    r.name as role_name,
    r.category as role_category,
    u.date_joined,
    u.is_active
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.email = 'coo@acemarket.com';
