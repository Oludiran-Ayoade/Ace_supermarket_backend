-- Populate all hierarchy users with credentials
-- Universal Password: password123 (hashed: $2a$10$rN8eH.6QhH5H5H5H5H5H5uO7vK8vK8vK8vK8vK8vK8vK8vK8vK8vK)
-- Note: You'll need to hash the password properly using bcrypt

-- First, let's get the role IDs we need
DO $$
DECLARE
    ceo_role_id UUID;
    coo_role_id UUID;
    chairman_role_id UUID;
    hr_role_id UUID;
    auditor_role_id UUID;
    group_head_supermarket_id UUID;
    group_head_eatery_id UUID;
    group_head_lounge_id UUID;
    group_head_arcade_id UUID;
    group_head_compliance_id UUID;
    group_head_facility_id UUID;
    supervisor_role_id UUID;
    dept_supermarket_id UUID;
    dept_eatery_id UUID;
    dept_lounge_id UUID;
    dept_arcade_id UUID;
    dept_compliance_id UUID;
    dept_facility_id UUID;
BEGIN
    -- Get role IDs
    SELECT id INTO ceo_role_id FROM roles WHERE name = 'CEO' LIMIT 1;
    SELECT id INTO coo_role_id FROM roles WHERE name = 'COO' LIMIT 1;
    SELECT id INTO chairman_role_id FROM roles WHERE name = 'Chairman' LIMIT 1;
    SELECT id INTO hr_role_id FROM roles WHERE name = 'HR Manager' OR name LIKE '%HR%' LIMIT 1;
    SELECT id INTO auditor_role_id FROM roles WHERE name LIKE '%Auditor%' LIMIT 1;
    
    -- Get Group Head role IDs
    SELECT id INTO group_head_supermarket_id FROM roles WHERE name = 'Group Head (SuperMarket)' LIMIT 1;
    SELECT id INTO group_head_eatery_id FROM roles WHERE name = 'Group Head (Eatery)' LIMIT 1;
    SELECT id INTO group_head_lounge_id FROM roles WHERE name = 'Group Head (Lounge)' LIMIT 1;
    SELECT id INTO group_head_arcade_id FROM roles WHERE name = 'Group Head (Fun & Arcade)' LIMIT 1;
    SELECT id INTO group_head_compliance_id FROM roles WHERE name = 'Group Head (Compliance)' LIMIT 1;
    SELECT id INTO group_head_facility_id FROM roles WHERE name = 'Group Head (Facility Management)' LIMIT 1;
    
    -- Get Supervisor role (we'll use a generic supervisor role)
    SELECT id INTO supervisor_role_id FROM roles WHERE name LIKE '%Supervisor%' LIMIT 1;
    
    -- Get Department IDs
    SELECT id INTO dept_supermarket_id FROM departments WHERE name = 'SuperMarket' LIMIT 1;
    SELECT id INTO dept_eatery_id FROM departments WHERE name = 'Eatery' LIMIT 1;
    SELECT id INTO dept_lounge_id FROM departments WHERE name = 'Lounge' LIMIT 1;
    SELECT id INTO dept_arcade_id FROM departments WHERE name = 'Fun & Arcade' LIMIT 1;
    SELECT id INTO dept_compliance_id FROM departments WHERE name = 'Compliance' LIMIT 1;
    SELECT id INTO dept_facility_id FROM departments WHERE name = 'Facility Management' LIMIT 1;

    -- Insert Senior Admin (CEO, COO, Chairman, HR, Auditors)
    -- CEO
    INSERT INTO users (id, email, password_hash, full_name, role_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'ceo@acemarket.com',
        '$2a$10$YourHashedPasswordHere', -- Replace with actual bcrypt hash of 'password123'
        'Mr. Adewale Johnson',
        ceo_role_id,
        'senior_admin',
        'ACE-CEO-001',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    -- COO
    INSERT INTO users (id, email, password_hash, full_name, role_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'coo@acemarket.com',
        '$2a$10$YourHashedPasswordHere',
        'Mrs. Folake Adeyemi',
        coo_role_id,
        'senior_admin',
        'ACE-COO-001',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    -- Chairman
    INSERT INTO users (id, email, password_hash, full_name, role_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'chairman@acemarket.com',
        '$2a$10$YourHashedPasswordHere',
        'Chief Oluwaseun Akinola',
        chairman_role_id,
        'senior_admin',
        'ACE-CHR-001',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    -- HR Manager
    INSERT INTO users (id, email, password_hash, full_name, role_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'hr@acemarket.com',
        '$2a$10$YourHashedPasswordHere',
        'Miss Blessing Okonkwo',
        hr_role_id,
        'senior_admin',
        'ACE-HR-001',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    -- Auditor 1
    INSERT INTO users (id, email, password_hash, full_name, role_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'auditor1@acemarket.com',
        '$2a$10$YourHashedPasswordHere',
        'Mr. Chukwudi Nwosu',
        auditor_role_id,
        'senior_admin',
        'ACE-AUD-001',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    -- Auditor 2
    INSERT INTO users (id, email, password_hash, full_name, role_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'auditor2@acemarket.com',
        '$2a$10$YourHashedPasswordHere',
        'Mrs. Amaka Okafor',
        auditor_role_id,
        'senior_admin',
        'ACE-AUD-002',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    -- Group Heads
    -- Group Head - SuperMarket
    INSERT INTO users (id, email, password_hash, full_name, role_id, department_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'gh.supermarket@acemarket.com',
        '$2a$10$YourHashedPasswordHere',
        'Mr. Tunde Bakare',
        group_head_supermarket_id,
        dept_supermarket_id,
        'admin',
        'ACE-GH-SM-001',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    -- Group Head - Eatery
    INSERT INTO users (id, email, password_hash, full_name, role_id, department_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'gh.eatery@acemarket.com',
        '$2a$10$YourHashedPasswordHere',
        'Mrs. Ngozi Eze',
        group_head_eatery_id,
        dept_eatery_id,
        'admin',
        'ACE-GH-ET-001',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    -- Group Head - Lounge
    INSERT INTO users (id, email, password_hash, full_name, role_id, department_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'gh.lounge@acemarket.com',
        '$2a$10$YourHashedPasswordHere',
        'Mr. Segun Afolabi',
        group_head_lounge_id,
        dept_lounge_id,
        'admin',
        'ACE-GH-LG-001',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    -- Group Head - Fun & Arcade
    INSERT INTO users (id, email, password_hash, full_name, role_id, department_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'gh.arcade@acemarket.com',
        '$2a$10$YourHashedPasswordHere',
        'Miss Funke Adeyemi',
        group_head_arcade_id,
        dept_arcade_id,
        'admin',
        'ACE-GH-AR-001',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    -- Group Head - Compliance
    INSERT INTO users (id, email, password_hash, full_name, role_id, department_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'gh.compliance@acemarket.com',
        '$2a$10$YourHashedPasswordHere',
        'Mr. Ibrahim Yusuf',
        group_head_compliance_id,
        dept_compliance_id,
        'admin',
        'ACE-GH-CP-001',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    -- Group Head - Facility Management
    INSERT INTO users (id, email, password_hash, full_name, role_id, department_id, category, employee_id, date_joined, is_active)
    VALUES (
        gen_random_uuid(),
        'gh.facility@acemarket.com',
        '$2a$10$YourHashedPasswordHere',
        'Mr. Emeka Obi',
        group_head_facility_id,
        dept_facility_id,
        'admin',
        'ACE-GH-FM-001',
        CURRENT_DATE,
        true
    ) ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash,
        full_name = EXCLUDED.full_name;

    RAISE NOTICE 'Hierarchy users populated successfully!';
END $$;
