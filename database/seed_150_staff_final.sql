-- Seed 150 Staff Members - Final Version
-- Uses actual role names from database
-- Password: "password123" (bcrypt hash: $2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi)

BEGIN;

-- Clear existing data
DELETE FROM shift_templates;
DELETE FROM weekly_reviews;
DELETE FROM roster_assignments;
DELETE FROM rosters;
DELETE FROM document_access_logs;
DELETE FROM users WHERE email != 'hr@acemarket.com';

-- ============================================================================
-- SENIOR ADMIN (12 staff)
-- ============================================================================

INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
VALUES
    -- CEO
    (gen_random_uuid(), 'ceo@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Chief Adebayo Williams', 'Male', '1975-03-15', '+234-803-100-0001', 'ACE-CEO-001',
     (SELECT id FROM roles WHERE name = 'Chief Executive Officer'), NULL, NULL,
     '2020-01-01', 15000000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- COO
    (gen_random_uuid(), 'coo@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mrs. Folake Okonkwo', 'Female', '1978-07-22', '+234-803-100-0002', 'ACE-COO-001',
     (SELECT id FROM roles WHERE name = 'Chief Operating Officer'), NULL, NULL,
     '2020-01-01', 12000000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- HR 1
    (gen_random_uuid(), 'hr1@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mr. Chukwuma Nwosu', 'Male', '1982-05-10', '+234-803-100-0003', 'ACE-HR-001',
     (SELECT id FROM roles WHERE name = 'HR Administrator'), NULL, NULL,
     '2020-02-01', 800000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- HR 2
    (gen_random_uuid(), 'hr2@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Miss Aisha Mohammed', 'Female', '1990-11-18', '+234-803-100-0004', 'ACE-HR-002',
     (SELECT id FROM roles WHERE name = 'HR Administrator'), NULL, NULL,
     '2021-03-15', 750000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Auditor 1
    (gen_random_uuid(), 'auditor1@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mr. Oluwaseun Adeyemi', 'Male', '1985-09-05', '+234-803-100-0005', 'ACE-AUD-001',
     (SELECT id FROM roles WHERE name = 'Auditor'), NULL, NULL,
     '2020-06-01', 900000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Auditor 2
    (gen_random_uuid(), 'auditor2@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mrs. Ngozi Eze', 'Female', '1987-12-20', '+234-803-100-0006', 'ACE-AUD-002',
     (SELECT id FROM roles WHERE name = 'Auditor'), NULL, NULL,
     '2021-01-10', 850000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Group Head - SuperMarket
    (gen_random_uuid(), 'gh.supermarket@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mr. Tunde Bakare', 'Male', '1980-04-12', '+234-803-100-0007', 'ACE-GH-SM-001',
     (SELECT id FROM roles WHERE name = 'Group Head (SuperMarket)'),
     (SELECT id FROM departments WHERE name = 'SuperMarket'), NULL,
     '2020-03-01', 1200000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Group Head - Lounge
    (gen_random_uuid(), 'gh.lounge@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mrs. Bimpe Oladele', 'Female', '1983-08-25', '+234-803-100-0008', 'ACE-GH-LG-001',
     (SELECT id FROM roles WHERE name = 'Group Head (Lounge)'),
     (SELECT id FROM departments WHERE name = 'Lounge'), NULL,
     '2020-04-01', 1100000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Group Head - Fun & Arcade
    (gen_random_uuid(), 'gh.arcade@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mr. Emeka Okafor', 'Male', '1981-06-30', '+234-803-100-0009', 'ACE-GH-AR-001',
     (SELECT id FROM roles WHERE name = 'Group Head (Fun & Arcade)'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'), NULL,
     '2020-05-01', 1000000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Group Head - Compliance
    (gen_random_uuid(), 'gh.compliance@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mrs. Fatima Abubakar', 'Female', '1984-02-14', '+234-803-100-0010', 'ACE-GH-CP-001',
     (SELECT id FROM roles WHERE name = 'Group Head (Compliance)'),
     (SELECT id FROM departments WHERE name = 'Compliance'), NULL,
     '2020-06-01', 1150000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Group Head - Eatery
    (gen_random_uuid(), 'gh.eatery@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mr. Adeola Ogunleye', 'Male', '1982-09-18', '+234-803-100-0011', 'ACE-GH-ET-001',
     (SELECT id FROM roles WHERE name = 'Group Head (Eatery)'),
     (SELECT id FROM departments WHERE name = 'Eatery'), NULL,
     '2020-07-01', 1100000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Group Head - Facility Management
    (gen_random_uuid(), 'gh.facility@acesupermarket.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'Mrs. Chidinma Okeke', 'Female', '1983-11-25', '+234-803-100-0012', 'ACE-GH-FM-001',
     (SELECT id FROM roles WHERE name = 'Group Head (Facility Management)'),
     (SELECT id FROM departments WHERE name = 'Facility Management'), NULL,
     '2020-08-01', 1050000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================================================
-- BRANCH MANAGERS (13 staff - SuperMarket)
-- ============================================================================

WITH branch_managers AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name) as rn,
        b.id as branch_id,
        b.name as branch_name
    FROM branches b
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'bm.' || LOWER(REPLACE(branch_name, 'Ace ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE rn
        WHEN 1 THEN 'Mr. Adewale Johnson'
        WHEN 2 THEN 'Mrs. Blessing Okoro'
        WHEN 3 THEN 'Mr. Ibrahim Yusuf'
        WHEN 4 THEN 'Mrs. Chioma Nwankwo'
        WHEN 5 THEN 'Mr. Kunle Adeleke'
        WHEN 6 THEN 'Mrs. Halima Bello'
        WHEN 7 THEN 'Mr. Segun Ogunleye'
        WHEN 8 THEN 'Mrs. Ronke Ajayi'
        WHEN 9 THEN 'Mr. Adekunle Oladipo'
        WHEN 10 THEN 'Mrs. Kemi Adebayo'
        WHEN 11 THEN 'Mr. Femi Ogunbiyi'
        WHEN 12 THEN 'Mrs. Yetunde Olatunji'
        ELSE 'Mr. Biodun Akinola'
    END,
    CASE WHEN rn % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1985-01-01' + (rn * 100 || ' days')::INTERVAL,
    '+234-803-200-' || LPAD(rn::TEXT, 4, '0'),
    'ACE-BM-' || LPAD(rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Branch Manager (SuperMarket)'),
    (SELECT id FROM departments WHERE name = 'SuperMarket'),
    branch_id,
    DATE '2021-01-01' + (rn * 30 || ' days')::INTERVAL,
    580000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM branch_managers;

-- ============================================================================
-- FLOOR MANAGERS (20 staff - SuperMarket and Lounge)
-- ============================================================================

WITH floor_managers_sm AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name) as rn,
        b.id as branch_id,
        b.name as branch_name
    FROM branches b
    LIMIT 10
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'fm.sm.' || LOWER(REPLACE(branch_name, 'Ace ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN rn % 2 = 1 THEN (ARRAY['Mr. Gbenga Afolabi', 'Mr. Tayo Olaleye', 'Mr. Wale Akinwande', 'Mr. Suleiman Abdullahi', 'Mr. Damilola Ogunbiyi'])[((rn-1) % 5) + 1]
        ELSE (ARRAY['Miss Funke Adeniyi', 'Miss Shade Ogunleye', 'Mrs. Bukola Adeyemi', 'Miss Zainab Ibrahim', 'Mrs. Folashade Ajayi'])[((rn-1) % 5) + 1]
    END,
    CASE WHEN rn % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1989-01-01' + (rn * 80 || ' days')::INTERVAL,
    '+234-803-300-' || LPAD(rn::TEXT, 4, '0'),
    'ACE-FM-SM-' || LPAD(rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Floor Manager (SuperMarket)'),
    (SELECT id FROM departments WHERE name = 'SuperMarket'),
    branch_id,
    DATE '2022-01-01' + (rn * 15 || ' days')::INTERVAL,
    330000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM floor_managers_sm;

WITH floor_managers_lg AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name) as rn,
        b.id as branch_id,
        b.name as branch_name
    FROM branches b
    LIMIT 10
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'fm.lg.' || LOWER(REPLACE(branch_name, 'Ace ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN rn % 2 = 1 THEN (ARRAY['Mr. Lanre Adebisi', 'Mr. Akeem Oladele', 'Mr. Chidi Okonkwo', 'Mr. Kayode Ajayi', 'Mr. Tosin Adekunle'])[((rn-1) % 5) + 1]
        ELSE (ARRAY['Mrs. Omolara Adeyinka', 'Miss Titilayo Ogunmola', 'Mrs. Amaka Obi', 'Miss Blessing Nwosu', 'Mrs. Kemi Oluwole'])[((rn-1) % 5) + 1]
    END,
    CASE WHEN rn % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1990-01-01' + (rn * 75 || ' days')::INTERVAL,
    '+234-803-310-' || LPAD(rn::TEXT, 4, '0'),
    'ACE-FM-LG-' || LPAD(rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Floor Manager (Lounge)'),
    (SELECT id FROM departments WHERE name = 'Lounge'),
    branch_id,
    DATE '2022-02-01' + (rn * 15 || ' days')::INTERVAL,
    320000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM floor_managers_lg;

-- Create shift templates for all floor managers
INSERT INTO shift_templates (id, floor_manager_id, shift_type, start_time, end_time, is_default, created_at, updated_at)
SELECT 
    gen_random_uuid(), u.id, 'day'::shift_type, '08:00:00'::TIME, '16:00:00'::TIME, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM users u INNER JOIN roles r ON u.role_id = r.id WHERE r.name LIKE 'Floor Manager%'
UNION ALL
SELECT 
    gen_random_uuid(), u.id, 'afternoon'::shift_type, '14:00:00'::TIME, '22:00:00'::TIME, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM users u INNER JOIN roles r ON u.role_id = r.id WHERE r.name LIKE 'Floor Manager%'
UNION ALL
SELECT 
    gen_random_uuid(), u.id, 'night'::shift_type, '22:00:00'::TIME, '06:00:00'::TIME, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM users u INNER JOIN roles r ON u.role_id = r.id WHERE r.name LIKE 'Floor Manager%';

-- ============================================================================
-- GENERAL STAFF (107 staff)
-- ============================================================================

-- Cashiers - SuperMarket (40 staff - 3 per branch)
WITH cashier_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name, s.num) as global_rn,
        b.id as branch_id,
        b.name as branch_name,
        s.num as staff_num
    FROM branches b
    CROSS JOIN generate_series(1, 3) s(num)
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'cashier' || global_rn || '.' || LOWER(REPLACE(branch_name, 'Ace ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN global_rn % 4 = 1 THEN 'Mr. Biodun Alabi'
        WHEN global_rn % 4 = 2 THEN 'Miss Funmi Oladele'
        WHEN global_rn % 4 = 3 THEN 'Mr. Tunde Ogunleye'
        ELSE 'Miss Bisi Adebayo'
    END,
    CASE WHEN global_rn % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1995-01-01' + (global_rn * 30 || ' days')::INTERVAL,
    '+234-803-400-' || LPAD(global_rn::TEXT, 4, '0'),
    'ACE-CASH-' || LPAD(global_rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Cashier (SuperMarket)'),
    (SELECT id FROM departments WHERE name = 'SuperMarket'),
    branch_id,
    DATE '2023-01-01' + (global_rn * 10 || ' days')::INTERVAL,
    120000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM cashier_data
LIMIT 40;

-- Waitress - Lounge (25 staff - 2 per branch)
WITH waiter_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name, s.num) as global_rn,
        b.id as branch_id,
        b.name as branch_name
    FROM branches b
    CROSS JOIN generate_series(1, 2) s(num)
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'waitress' || global_rn || '.' || LOWER(REPLACE(branch_name, 'Ace ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN global_rn % 2 = 1 THEN 'Mr. Segun Afolabi'
        ELSE 'Miss Kemi Adeniyi'
    END,
    CASE WHEN global_rn % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1996-01-01' + (global_rn * 25 || ' days')::INTERVAL,
    '+234-803-500-' || LPAD(global_rn::TEXT, 4, '0'),
    'ACE-WAIT-' || LPAD(global_rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Waitress (Lounge)'),
    (SELECT id FROM departments WHERE name = 'Lounge'),
    branch_id,
    DATE '2023-03-01' + (global_rn * 8 || ' days')::INTERVAL,
    100000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM waiter_data
LIMIT 25;

-- Security (20 staff - 2 per branch, first 10 branches)
WITH security_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name, s.num) as global_rn,
        b.id as branch_id,
        b.name as branch_name
    FROM branches b
    CROSS JOIN generate_series(1, 2) s(num)
    LIMIT 20
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'security' || global_rn || '.' || LOWER(REPLACE(branch_name, 'Ace ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN global_rn % 2 = 1 THEN 'Mr. Musa Ibrahim'
        ELSE 'Mr. Usman Bello'
    END,
    'Male',
    DATE '1990-01-01' + (global_rn * 40 || ' days')::INTERVAL,
    '+234-803-600-' || LPAD(global_rn::TEXT, 4, '0'),
    'ACE-SEC-' || LPAD(global_rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Security'),
    (SELECT id FROM departments WHERE name = 'Facility Management'),
    branch_id,
    DATE '2023-02-01' + (global_rn * 12 || ' days')::INTERVAL,
    90000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM security_data;

-- Cleaners (15 staff)
WITH cleaner_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name) as global_rn,
        b.id as branch_id,
        b.name as branch_name
    FROM branches b
    CROSS JOIN generate_series(1, 2) s(num)
    LIMIT 15
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'cleaner' || global_rn || '.' || LOWER(REPLACE(branch_name, 'Ace ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN global_rn % 2 = 1 THEN 'Mrs. Iya Bose'
        ELSE 'Mr. Baba Sule'
    END,
    CASE WHEN global_rn % 2 = 1 THEN 'Female' ELSE 'Male' END,
    DATE '1985-01-01' + (global_rn * 50 || ' days')::INTERVAL,
    '+234-803-700-' || LPAD(global_rn::TEXT, 4, '0'),
    'ACE-CLN-' || LPAD(global_rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Cleaner'),
    (SELECT id FROM departments WHERE name = 'Facility Management'),
    branch_id,
    DATE '2023-04-01' + (global_rn * 15 || ' days')::INTERVAL,
    70000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM cleaner_data;

-- Arcade Staff (7 staff)
WITH arcade_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name) as global_rn,
        b.id as branch_id,
        b.name as branch_name
    FROM branches b
    LIMIT 7
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'arcade' || global_rn || '.' || LOWER(REPLACE(branch_name, 'Ace ', '')) || '@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    CASE 
        WHEN global_rn % 2 = 1 THEN 'Mr. David Okon'
        ELSE 'Miss Joy Eze'
    END,
    CASE WHEN global_rn % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1997-01-01' + (global_rn * 35 || ' days')::INTERVAL,
    '+234-803-800-' || LPAD(global_rn::TEXT, 4, '0'),
    'ACE-ARC-' || LPAD(global_rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Arcade Staff'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    branch_id,
    DATE '2023-05-01' + (global_rn * 20 || ' days')::INTERVAL,
    95000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM arcade_data;

COMMIT;

-- Verification
SELECT 
    r.category,
    r.name as role_name,
    COUNT(*) as count
FROM users u
INNER JOIN roles r ON u.role_id = r.id
GROUP BY r.category, r.name
ORDER BY r.category, r.name;

SELECT 
    r.category,
    COUNT(*) as total
FROM users u
INNER JOIN roles r ON u.role_id = r.id
GROUP BY r.category
ORDER BY r.category;

SELECT COUNT(*) as total_staff FROM users;

SELECT 
    b.name as branch,
    COUNT(u.id) as staff_count
FROM branches b
LEFT JOIN users u ON b.id = u.branch_id
GROUP BY b.name
ORDER BY b.name;
