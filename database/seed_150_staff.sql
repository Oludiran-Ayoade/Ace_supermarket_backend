-- Seed 150 Staff Members Across All Branches and Roles
-- Run this after the main schema is set up
-- Password for all accounts: "password123" (hashed with bcrypt)

BEGIN;

-- Helper function to generate random phone numbers
CREATE OR REPLACE FUNCTION random_phone() RETURNS VARCHAR AS $$
BEGIN
    RETURN '+234-' || LPAD((800 + floor(random() * 100))::TEXT, 3, '0') || '-' || 
           LPAD(floor(random() * 1000000)::TEXT, 7, '0');
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- PART 1: SENIOR ADMIN (10 staff)
-- ============================================================================

-- CEO, COO, HR (2), Auditors (2), Group Heads (4)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
VALUES
    -- CEO
    (gen_random_uuid(), 'ceo@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Chief Adebayo Williams', 'Male', '1975-03-15', random_phone(), 'ACE-CEO-001',
     (SELECT id FROM roles WHERE name = 'Chief Executive Officer'), NULL, NULL,
     '2020-01-01', 15000000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- COO
    (gen_random_uuid(), 'coo@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mrs. Folake Okonkwo', 'Female', '1978-07-22', random_phone(), 'ACE-COO-001',
     (SELECT id FROM roles WHERE name = 'Chief Operating Officer'), NULL, NULL,
     '2020-01-01', 12000000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- HR 1
    (gen_random_uuid(), 'hr1@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mr. Chukwuma Nwosu', 'Male', '1982-05-10', random_phone(), 'ACE-HR-001',
     (SELECT id FROM roles WHERE name = 'Human Resource'), NULL, NULL,
     '2020-02-01', 800000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- HR 2
    (gen_random_uuid(), 'hr2@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Miss Aisha Mohammed', 'Female', '1990-11-18', random_phone(), 'ACE-HR-002',
     (SELECT id FROM roles WHERE name = 'Human Resource'), NULL, NULL,
     '2021-03-15', 750000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Auditor 1
    (gen_random_uuid(), 'auditor1@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mr. Oluwaseun Adeyemi', 'Male', '1985-09-05', random_phone(), 'ACE-AUD-001',
     (SELECT id FROM roles WHERE name = 'Auditor'), NULL, NULL,
     '2020-06-01', 900000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Auditor 2
    (gen_random_uuid(), 'auditor2@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mrs. Ngozi Eze', 'Female', '1987-12-20', random_phone(), 'ACE-AUD-002',
     (SELECT id FROM roles WHERE name = 'Auditor'), NULL, NULL,
     '2021-01-10', 850000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Group Head - SuperMarket
    (gen_random_uuid(), 'gh.supermarket@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mr. Tunde Bakare', 'Male', '1980-04-12', random_phone(), 'ACE-GH-SM-001',
     (SELECT id FROM roles WHERE name = 'Group Head'),
     (SELECT id FROM departments WHERE name = 'SuperMarket'), NULL,
     '2020-03-01', 1200000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Group Head - Lounge
    (gen_random_uuid(), 'gh.lounge@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mrs. Bimpe Oladele', 'Female', '1983-08-25', random_phone(), 'ACE-GH-LG-001',
     (SELECT id FROM roles WHERE name = 'Group Head'),
     (SELECT id FROM departments WHERE name = 'Lounge'), NULL,
     '2020-04-01', 1100000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Group Head - Fun & Arcade
    (gen_random_uuid(), 'gh.arcade@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mr. Emeka Okafor', 'Male', '1981-06-30', random_phone(), 'ACE-GH-AR-001',
     (SELECT id FROM roles WHERE name = 'Group Head'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'), NULL,
     '2020-05-01', 1000000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Group Head - Compliance
    (gen_random_uuid(), 'gh.compliance@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mrs. Fatima Abubakar', 'Female', '1984-02-14', random_phone(), 'ACE-GH-CP-001',
     (SELECT id FROM roles WHERE name = 'Group Head'),
     (SELECT id FROM departments WHERE name = 'Compliance'), NULL,
     '2020-06-01', 1150000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================================================
-- PART 2: BRANCH MANAGERS (13 staff - one per branch)
-- ============================================================================

WITH branch_data AS (
    SELECT 
        b.id as branch_id,
        b.name as branch_name,
        ROW_NUMBER() OVER (ORDER BY b.name) as rn
    FROM branches b
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'bm.' || LOWER(REPLACE(branch_name, ' ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN rn % 2 = 1 THEN 'Mr. ' || (ARRAY['Adewale Johnson', 'Ibrahim Yusuf', 'Kunle Adeleke', 'Segun Ogunleye', 'Adekunle Oladipo', 'Femi Ogunbiyi', 'Biodun Akinola'])[((rn-1)/2 % 7) + 1]
        ELSE 'Mrs. ' || (ARRAY['Blessing Okoro', 'Chioma Nwankwo', 'Halima Bello', 'Ronke Ajayi', 'Kemi Adebayo', 'Yetunde Olatunji'])[((rn-1)/2 % 6) + 1]
    END,
    CASE WHEN rn % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1985-01-01' + (rn * 100 || ' days')::INTERVAL,
    random_phone(),
    'ACE-BM-' || SUBSTRING(UPPER(REPLACE(branch_name, ' ', '')), 1, 3) || '-' || LPAD(rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Branch Manager'),
    branch_id,
    DATE '2021-01-01' + (rn * 30 || ' days')::INTERVAL,
    580000.00 + (rn * 5000),
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM branch_data;

-- ============================================================================
-- PART 3: FLOOR MANAGERS (20 staff - distributed across branches)
-- ============================================================================

WITH branch_dept_combo AS (
    SELECT 
        b.id as branch_id,
        b.name as branch_name,
        d.id as dept_id,
        d.name as dept_name,
        ROW_NUMBER() OVER (ORDER BY b.name, d.name) as rn
    FROM branches b
    CROSS JOIN departments d
    WHERE d.name IN ('SuperMarket', 'Lounge')
    LIMIT 20
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'fm.' || LOWER(REPLACE(branch_name, ' ', '')) || '.' || LOWER(SUBSTRING(dept_name, 1, 2)) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN rn % 2 = 1 THEN 'Mr. ' || (ARRAY['Gbenga Afolabi', 'Tayo Olaleye', 'Wale Akinwande', 'Suleiman Abdullahi', 'Damilola Ogunbiyi', 'Lanre Adebisi', 'Akeem Oladele', 'Chidi Okonkwo', 'Kayode Ajayi', 'Tosin Adekunle'])[((rn-1) % 10) + 1]
        ELSE 'Miss ' || (ARRAY['Funke Adeniyi', 'Shade Ogunleye', 'Bukola Adeyemi', 'Zainab Ibrahim', 'Folashade Ajayi', 'Omolara Adeyinka', 'Titilayo Ogunmola', 'Amaka Obi', 'Blessing Nwosu', 'Kemi Oluwole'])[((rn-1) % 10) + 1]
    END,
    CASE WHEN rn % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1989-01-01' + (rn * 80 || ' days')::INTERVAL,
    random_phone(),
    'ACE-FM-' || SUBSTRING(UPPER(REPLACE(branch_name, ' ', '')), 1, 3) || '-' || SUBSTRING(UPPER(dept_name), 1, 2) || '-' || LPAD(rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Floor Manager'),
    dept_id,
    branch_id,
    DATE '2022-01-01' + (rn * 15 || ' days')::INTERVAL,
    320000.00 + (rn * 2000),
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM branch_dept_combo;

-- Create shift templates for all floor managers
INSERT INTO shift_templates (id, floor_manager_id, shift_type, start_time, end_time, is_default, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    u.id,
    'day',
    '08:00:00',
    '16:00:00',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM users u
INNER JOIN roles r ON u.role_id = r.id
WHERE r.name = 'Floor Manager';

INSERT INTO shift_templates (id, floor_manager_id, shift_type, start_time, end_time, is_default, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    u.id,
    'afternoon',
    '14:00:00',
    '22:00:00',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM users u
INNER JOIN roles r ON u.role_id = r.id
WHERE r.name = 'Floor Manager';

INSERT INTO shift_templates (id, floor_manager_id, shift_type, start_time, end_time, is_default, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    u.id,
    'night',
    '22:00:00',
    '06:00:00',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM users u
INNER JOIN roles r ON u.role_id = r.id
WHERE r.name = 'Floor Manager';

-- ============================================================================
-- PART 4: GENERAL STAFF (107 staff - distributed across all branches)
-- ============================================================================

-- Cashiers (40 staff)
WITH branch_data AS (
    SELECT 
        b.id as branch_id,
        b.name as branch_name,
        (SELECT id FROM departments WHERE name = 'SuperMarket') as dept_id,
        ROW_NUMBER() OVER (ORDER BY b.name) as branch_num
    FROM branches b
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'cashier' || s.num || '.' || LOWER(REPLACE(bd.branch_name, ' ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN s.num % 2 = 1 THEN 'Mr. ' || (ARRAY['Biodun Alabi', 'Tunde Ogunleye', 'Yemi Adeyemi', 'Kunle Ajayi'])[((s.num-1) % 4) + 1]
        ELSE 'Miss ' || (ARRAY['Funmi Oladele', 'Bisi Adebayo', 'Tope Okonkwo', 'Sade Nwosu'])[((s.num-1) % 4) + 1]
    END,
    CASE WHEN s.num % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1995-01-01' + (s.num * 30 || ' days')::INTERVAL,
    random_phone(),
    'ACE-CASH-' || SUBSTRING(UPPER(REPLACE(bd.branch_name, ' ', '')), 1, 3) || '-' || LPAD(s.num::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Cashier'),
    bd.dept_id,
    bd.branch_id,
    DATE '2023-01-01' + (s.num * 10 || ' days')::INTERVAL,
    120000.00 + (s.num * 1000),
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM branch_data bd
CROSS JOIN generate_series(1, 3) s(num);

-- Waiters/Waitresses (25 staff)
WITH branch_data AS (
    SELECT 
        b.id as branch_id,
        b.name as branch_name,
        (SELECT id FROM departments WHERE name = 'Lounge') as dept_id,
        ROW_NUMBER() OVER (ORDER BY b.name) as branch_num
    FROM branches b
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'waiter' || s.num || '.' || LOWER(REPLACE(bd.branch_name, ' ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN s.num % 2 = 1 THEN 'Mr. ' || (ARRAY['Segun Afolabi', 'Wale Ogunbiyi'])[((s.num-1) % 2) + 1]
        ELSE 'Miss ' || (ARRAY['Kemi Adeniyi', 'Shade Olaleye'])[((s.num-1) % 2) + 1]
    END,
    CASE WHEN s.num % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1996-01-01' + (s.num * 25 || ' days')::INTERVAL,
    random_phone(),
    'ACE-WAIT-' || SUBSTRING(UPPER(REPLACE(bd.branch_name, ' ', '')), 1, 3) || '-' || LPAD(s.num::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Waiter/Waitress'),
    bd.dept_id,
    bd.branch_id,
    DATE '2023-03-01' + (s.num * 8 || ' days')::INTERVAL,
    100000.00 + (s.num * 800),
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM branch_data bd
CROSS JOIN generate_series(1, 2) s(num);

-- Security Guards (20 staff)
WITH branch_data AS (
    SELECT 
        b.id as branch_id,
        b.name as branch_name,
        (SELECT id FROM departments WHERE name = 'Facility Management') as dept_id
    FROM branches b
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'security' || s.num || '.' || LOWER(REPLACE(bd.branch_name, ' ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'Mr. ' || (ARRAY['Musa Ibrahim', 'Usman Bello'])[((s.num-1) % 2) + 1],
    'Male',
    DATE '1990-01-01' + (s.num * 40 || ' days')::INTERVAL,
    random_phone(),
    'ACE-SEC-' || SUBSTRING(UPPER(REPLACE(bd.branch_name, ' ', '')), 1, 3) || '-' || LPAD(s.num::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Security Guard'),
    bd.dept_id,
    bd.branch_id,
    DATE '2023-02-01' + (s.num * 12 || ' days')::INTERVAL,
    90000.00 + (s.num * 500),
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM branch_data bd
CROSS JOIN generate_series(1, 2) s(num)
LIMIT 20;

-- Cleaners (15 staff)
WITH branch_data AS (
    SELECT 
        b.id as branch_id,
        b.name as branch_name,
        (SELECT id FROM departments WHERE name = 'Facility Management') as dept_id
    FROM branches b
    LIMIT 10
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'cleaner' || s.num || '.' || LOWER(REPLACE(bd.branch_name, ' ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN s.num % 2 = 1 THEN 'Mrs. ' || (ARRAY['Iya Bose', 'Mama Kudi'])[((s.num-1) % 2) + 1]
        ELSE 'Mr. ' || (ARRAY['Baba Sule', 'Mallam Isa'])[((s.num-1) % 2) + 1]
    END,
    CASE WHEN s.num % 2 = 1 THEN 'Female' ELSE 'Male' END,
    DATE '1985-01-01' + (s.num * 50 || ' days')::INTERVAL,
    random_phone(),
    'ACE-CLN-' || SUBSTRING(UPPER(REPLACE(bd.branch_name, ' ', '')), 1, 3) || '-' || LPAD(s.num::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Cleaner'),
    bd.dept_id,
    bd.branch_id,
    DATE '2023-04-01' + (s.num * 15 || ' days')::INTERVAL,
    70000.00 + (s.num * 300),
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM branch_data bd
CROSS JOIN generate_series(1, 2) s(num)
LIMIT 15;

-- Arcade Attendants (7 staff)
WITH branch_data AS (
    SELECT 
        b.id as branch_id,
        b.name as branch_name,
        (SELECT id FROM departments WHERE name = 'Fun & Arcade') as dept_id
    FROM branches b
    LIMIT 7
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'arcade.' || LOWER(REPLACE(bd.branch_name, ' ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN ROW_NUMBER() OVER () % 2 = 1 THEN 'Mr. David Okon'
        ELSE 'Miss Joy Eze'
    END,
    CASE WHEN ROW_NUMBER() OVER () % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1997-01-01' + (ROW_NUMBER() OVER () * 35 || ' days')::INTERVAL,
    random_phone(),
    'ACE-ARC-' || SUBSTRING(UPPER(REPLACE(bd.branch_name, ' ', '')), 1, 3) || '-001',
    (SELECT id FROM roles WHERE name = 'Arcade Attendant'),
    bd.dept_id,
    bd.branch_id,
    DATE '2023-05-01' + (ROW_NUMBER() OVER () * 20 || ' days')::INTERVAL,
    95000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM branch_data bd;

-- Drop helper function
DROP FUNCTION IF EXISTS random_phone();

COMMIT;

-- Verification Query
SELECT 
    r.category,
    r.name as role_name,
    COUNT(*) as staff_count
FROM users u
INNER JOIN roles r ON u.role_id = r.id
GROUP BY r.category, r.name
ORDER BY r.category, r.name;

-- Total count
SELECT COUNT(*) as total_staff FROM users;
