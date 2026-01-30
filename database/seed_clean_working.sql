-- Clean Working Seed File - Simple Email Formats
-- Password for ALL: "password123"
-- Hash: $2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS

BEGIN;

-- Clear ALL existing users
DELETE FROM shift_templates;
DELETE FROM weekly_reviews;
DELETE FROM roster_assignments;
DELETE FROM rosters;
DELETE FROM document_access_logs;
DELETE FROM users;

-- ============================================================================
-- SENIOR ADMIN (7 staff)
-- ============================================================================

INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
VALUES
    -- CEO
    (gen_random_uuid(), 'ceo@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Chief Adebayo Williams', 'Male', '1975-03-15', '+234-803-100-0001', 'ACE-CEO-001',
     (SELECT id FROM roles WHERE name = 'Chief Executive Officer'), NULL, NULL,
     '2020-01-01', 15000000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- COO
    (gen_random_uuid(), 'coo@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mrs. Folake Okonkwo', 'Female', '1978-07-22', '+234-803-100-0002', 'ACE-COO-001',
     (SELECT id FROM roles WHERE name = 'Chief Operating Officer'), NULL, NULL,
     '2020-01-01', 12000000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- HR 1
    (gen_random_uuid(), 'hr@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mr. Chukwuma Nwosu', 'Male', '1982-05-10', '+234-803-100-0003', 'ACE-HR-001',
     (SELECT id FROM roles WHERE name = 'Human Resource'), NULL, NULL,
     '2020-02-01', 800000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- HR 2
    (gen_random_uuid(), 'hr2@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Miss Aisha Mohammed', 'Female', '1990-11-18', '+234-803-100-0004', 'ACE-HR-002',
     (SELECT id FROM roles WHERE name = 'Human Resource'), NULL, NULL,
     '2021-03-15', 750000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Auditor 1
    (gen_random_uuid(), 'auditor@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mr. Tunde Bakare', 'Male', '1980-09-12', '+234-803-100-0005', 'ACE-AUD-001',
     (SELECT id FROM roles WHERE name = 'Auditor'), NULL, NULL,
     '2020-03-01', 700000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Auditor 2
    (gen_random_uuid(), 'auditor2@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mrs. Ngozi Okafor', 'Female', '1983-06-20', '+234-803-100-0006', 'ACE-AUD-002',
     (SELECT id FROM roles WHERE name = 'Auditor'), NULL, NULL,
     '2020-04-01', 680000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    -- Chairman
    (gen_random_uuid(), 'chairman@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Chief Akinwale Adeyemi', 'Male', '1965-12-05', '+234-803-100-0007', 'ACE-CHR-001',
     (SELECT id FROM roles WHERE name = 'Chairman'), NULL, NULL,
     '2019-01-01', 20000000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================================================
-- BRANCH MANAGERS (13 staff - Simple format: bm.{branch}@)
-- ============================================================================

WITH branch_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name) as rn,
        b.id as branch_id,
        LOWER(REPLACE(REPLACE(b.name, 'Ace Mall, ', ''), ' ', '')) as branch_slug
    FROM branches b
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'bm.' || branch_slug || '@acesupermarket.com',
    '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
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
    DATE '1975-01-01' + (rn * 100 || ' days')::INTERVAL,
    '+234-803-200-' || LPAD(rn::TEXT, 4, '0'),
    'ACE-BM-' || LPAD(rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name LIKE 'Branch Manager%' LIMIT 1),
    branch_id,
    DATE '2021-01-01' + (rn * 10 || ' days')::INTERVAL,
    500000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM branch_data;

-- ============================================================================
-- FLOOR MANAGERS (20 staff - Format: fm.{branch}.lounge@ or fm.{branch}.supermarket@)
-- ============================================================================

WITH floor_managers AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name, d.name) as rn,
        b.id as branch_id,
        LOWER(REPLACE(REPLACE(b.name, 'Ace Mall, ', ''), ' ', '')) as branch_slug,
        d.id as dept_id,
        LOWER(d.name) as dept_slug,
        d.name as dept_name
    FROM branches b
    CROSS JOIN departments d
    WHERE d.name IN ('SuperMarket', 'Lounge')
    LIMIT 20
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'fm.' || branch_slug || '.' || dept_slug || '@acesupermarket.com',
    '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
    CASE 
        WHEN rn % 2 = 1 THEN (ARRAY['Mr. Gbenga Afolabi', 'Mr. Tayo Olaleye', 'Mr. Wale Akinwande', 'Mr. Suleiman Abdullahi', 'Mr. Damilola Ogunbiyi', 'Mr. Lanre Adebisi', 'Mr. Akeem Oladele', 'Mr. Chidi Okonkwo', 'Mr. Kayode Ajayi', 'Mr. Tosin Adekunle'])[((rn-1) % 10) + 1]
        ELSE (ARRAY['Miss Funke Adeniyi', 'Miss Shade Ogunleye', 'Mrs. Bukola Adeyemi', 'Miss Zainab Ibrahim', 'Mrs. Folashade Ajayi', 'Mrs. Omolara Adeyinka', 'Miss Titilayo Ogunmola', 'Mrs. Amaka Obi', 'Miss Blessing Nwosu', 'Mrs. Kemi Oluwole'])[((rn-1) % 10) + 1]
    END,
    CASE WHEN rn % 2 = 1 THEN 'Male' ELSE 'Female' END,
    DATE '1989-01-01' + (rn * 80 || ' days')::INTERVAL,
    '+234-803-300-' || LPAD(rn::TEXT, 4, '0'),
    'ACE-FM-' || LPAD(rn::TEXT, 3, '0'),
    (SELECT id FROM roles WHERE name = 'Floor Manager (' || dept_name || ')' AND department_id = dept_id LIMIT 1),
    dept_id,
    branch_id,
    DATE '2022-01-01' + (rn * 15 || ' days')::INTERVAL,
    330000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM floor_managers;

-- Create shift templates for floor managers
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
-- SUB-DEPARTMENT MANAGERS (15 staff - Cinema, Photo Studio, Saloon, Arcade, Casino)
-- ============================================================================

-- Cinema Supervisors (3)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, sub_department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
VALUES
    (gen_random_uuid(), 'cinema.abeokuta@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mr. Tayo Adeyemi', 'Male', '1988-03-15', '+234-803-500-0001', 'ACE-CIN-001',
     (SELECT id FROM roles WHERE name = 'Cinema Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Cinema'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Abeokuta'),
     DATE '2022-06-01', 350000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    (gen_random_uuid(), 'cinema.bodija@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Miss Funke Oladele', 'Female', '1990-07-22', '+234-803-500-0002', 'ACE-CIN-002',
     (SELECT id FROM roles WHERE name = 'Cinema Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Cinema'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Bodija'),
     DATE '2022-04-15', 350000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    (gen_random_uuid(), 'cinema.akobo@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mr. Segun Afolabi', 'Male', '1987-11-10', '+234-803-500-0003', 'ACE-CIN-003',
     (SELECT id FROM roles WHERE name = 'Cinema Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Cinema'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Akobo'),
     DATE '2022-07-01', 350000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Photo Studio Supervisors (3)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, sub_department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
VALUES
    (gen_random_uuid(), 'photostudio.abeokuta@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mrs. Kemi Adebayo', 'Female', '1989-05-18', '+234-803-500-0004', 'ACE-PHO-001',
     (SELECT id FROM roles WHERE name = 'Photo Studio Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Photo Studio'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Abeokuta'),
     DATE '2022-05-10', 340000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    (gen_random_uuid(), 'photostudio.bodija@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mr. Wale Ogunbiyi', 'Male', '1986-09-25', '+234-803-500-0005', 'ACE-PHO-002',
     (SELECT id FROM roles WHERE name = 'Photo Studio Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Photo Studio'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Bodija'),
     DATE '2022-03-20', 340000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    (gen_random_uuid(), 'photostudio.akobo@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Miss Shade Akinola', 'Female', '1991-12-08', '+234-803-500-0006', 'ACE-PHO-003',
     (SELECT id FROM roles WHERE name = 'Photo Studio Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Photo Studio'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Akobo'),
     DATE '2022-08-15', 340000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Saloon Supervisors (3)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, sub_department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
VALUES
    (gen_random_uuid(), 'saloon.abeokuta@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Miss Blessing Okoro', 'Female', '1992-02-14', '+234-803-500-0007', 'ACE-SAL-001',
     (SELECT id FROM roles WHERE name = 'Saloon Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Saloon'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Abeokuta'),
     DATE '2022-02-28', 330000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    (gen_random_uuid(), 'saloon.bodija@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mr. Gbenga Fashola', 'Male', '1988-06-30', '+234-803-500-0008', 'ACE-SAL-002',
     (SELECT id FROM roles WHERE name = 'Saloon Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Saloon'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Bodija'),
     DATE '2022-06-10', 330000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    (gen_random_uuid(), 'saloon.akobo@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mrs. Yetunde Olatunji', 'Female', '1987-10-05', '+234-803-500-0009', 'ACE-SAL-003',
     (SELECT id FROM roles WHERE name = 'Saloon Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Saloon'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Akobo'),
     DATE '2022-05-20', 330000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Arcade Supervisors (3)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, sub_department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
VALUES
    (gen_random_uuid(), 'arcade.abeokuta@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mr. Kunle Adeleke', 'Male', '1990-04-12', '+234-803-500-0010', 'ACE-ARC-001',
     (SELECT id FROM roles WHERE name = 'Arcade Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Arcade & Kiddies Park'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Abeokuta'),
     DATE '2022-07-15', 340000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    (gen_random_uuid(), 'arcade.bodija@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Miss Zainab Ibrahim', 'Female', '1991-08-20', '+234-803-500-0011', 'ACE-ARC-002',
     (SELECT id FROM roles WHERE name = 'Arcade Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Arcade & Kiddies Park'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Bodija'),
     DATE '2022-04-05', 340000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    (gen_random_uuid(), 'arcade.akobo@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mr. Biodun Alabi', 'Male', '1989-11-28', '+234-803-500-0012', 'ACE-ARC-003',
     (SELECT id FROM roles WHERE name = 'Arcade Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Arcade & Kiddies Park'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Akobo'),
     DATE '2022-06-18', 340000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Casino Supervisors (3)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, sub_department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
VALUES
    (gen_random_uuid(), 'casino.abeokuta@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mr. Chidi Okonkwo', 'Male', '1987-03-22', '+234-803-500-0013', 'ACE-CAS-001',
     (SELECT id FROM roles WHERE name = 'Casino Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Casino'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Abeokuta'),
     DATE '2022-03-10', 360000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    (gen_random_uuid(), 'casino.bodija@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mrs. Amaka Nwosu', 'Female', '1988-07-16', '+234-803-500-0014', 'ACE-CAS-002',
     (SELECT id FROM roles WHERE name = 'Casino Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Casino'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Bodija'),
     DATE '2022-05-25', 360000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    
    (gen_random_uuid(), 'casino.akobo@acesupermarket.com', '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
     'Mr. Lanre Adebisi', 'Male', '1990-09-12', '+234-803-500-0015', 'ACE-CAS-003',
     (SELECT id FROM roles WHERE name = 'Casino Supervisor'),
     (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
     (SELECT id FROM sub_departments WHERE name = 'Casino'),
     (SELECT id FROM branches WHERE name = 'Ace Mall, Akobo'),
     DATE '2022-07-30', 360000.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Create shift templates for sub-department supervisors (they function like floor managers)
INSERT INTO shift_templates (id, floor_manager_id, shift_type, start_time, end_time, is_default, created_at, updated_at)
SELECT 
    gen_random_uuid(), u.id, 'day'::shift_type, '08:00:00'::TIME, '16:00:00'::TIME, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM users u INNER JOIN roles r ON u.role_id = r.id 
WHERE r.name IN ('Cinema Supervisor', 'Photo Studio Supervisor', 'Saloon Supervisor', 'Arcade Supervisor', 'Casino Supervisor')
UNION ALL
SELECT 
    gen_random_uuid(), u.id, 'afternoon'::shift_type, '14:00:00'::TIME, '22:00:00'::TIME, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM users u INNER JOIN roles r ON u.role_id = r.id 
WHERE r.name IN ('Cinema Supervisor', 'Photo Studio Supervisor', 'Saloon Supervisor', 'Arcade Supervisor', 'Casino Supervisor')
UNION ALL
SELECT 
    gen_random_uuid(), u.id, 'night'::shift_type, '22:00:00'::TIME, '06:00:00'::TIME, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM users u INNER JOIN roles r ON u.role_id = r.id 
WHERE r.name IN ('Cinema Supervisor', 'Photo Studio Supervisor', 'Saloon Supervisor', 'Arcade Supervisor', 'Casino Supervisor');

-- ============================================================================
-- GENERAL STAFF - CASHIERS (30 staff - Format: cashier.{branch}{number}@)
-- ============================================================================

WITH cashier_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name, s.num) as global_rn,
        b.id as branch_id,
        LOWER(REPLACE(REPLACE(b.name, 'Ace Mall, ', ''), ' ', '')) as branch_slug,
        s.num as staff_num
    FROM branches b
    CROSS JOIN generate_series(1, 2) s(num)
    LIMIT 30
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'cashier.' || branch_slug || staff_num || '@acesupermarket.com',
    '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
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
    DATE '2023-01-01' + (global_rn * 5 || ' days')::INTERVAL,
    120000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM cashier_data;

-- ============================================================================
-- GENERAL STAFF - WAITERS (20 staff - Format: waiter.{branch}{number}@)
-- ============================================================================

WITH waiter_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.name, s.num) as global_rn,
        b.id as branch_id,
        LOWER(REPLACE(REPLACE(b.name, 'Ace Mall, ', ''), ' ', '')) as branch_slug,
        s.num as staff_num
    FROM branches b
    CROSS JOIN generate_series(1, 2) s(num)
    LIMIT 20
)
INSERT INTO users (id, email, password_hash, full_name, gender, date_of_birth, phone_number, 
    employee_id, role_id, department_id, branch_id, date_joined, current_salary, is_active, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'waiter.' || branch_slug || staff_num || '@acesupermarket.com',
    '$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS',
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
    DATE '2023-02-01' + (global_rn * 5 || ' days')::INTERVAL,
    100000.00,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM waiter_data;

COMMIT;

-- Summary
SELECT 
    r.category,
    r.name as role_name,
    COUNT(*) as count
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
GROUP BY r.category, r.name
ORDER BY r.category, r.name;

SELECT 
    r.category,
    COUNT(*) as total
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
GROUP BY r.category
ORDER BY r.category;

SELECT COUNT(*) as total_staff FROM users;
