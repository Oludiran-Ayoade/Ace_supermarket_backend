-- Seed Senior Admin Users (CEO, COO, HR, Auditors) for Ace Mall Staff Management System
-- These are the top-level administrators who can oversee all staff and operations
-- Note: CEO and Chairman are the same person

DO $$
DECLARE
    ceo_role_id UUID;
    coo_role_id UUID;
    hr_role_id UUID;
    auditor_role_id UUID;
BEGIN
    -- Get role IDs
    SELECT id INTO ceo_role_id FROM roles WHERE name = 'Chief Executive Officer' LIMIT 1;
    SELECT id INTO coo_role_id FROM roles WHERE name = 'Chief Operating Officer' LIMIT 1;
    SELECT id INTO hr_role_id FROM roles WHERE name = 'Human Resource' LIMIT 1;
    SELECT id INTO auditor_role_id FROM roles WHERE name = 'Auditor' LIMIT 1;
    
    -- Insert CEO user (also serves as Chairman)
    -- Email: ceo@acemarket.com
    -- Password: password123
    INSERT INTO users (
        id, email, password_hash, full_name, role_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'ceo@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Chief John Adebayo',
        ceo_role_id,
        CURRENT_DATE,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- Insert COO user
    -- Email: coo@acemarket.com
    -- Password: password123
    INSERT INTO users (
        id, email, password_hash, full_name, role_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'coo@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Sarah Ogunleye',
        coo_role_id,
        CURRENT_DATE,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- Insert HR Manager user
    -- Can create accounts for everyone and oversee all operations
    -- Email: hr@acemarket.com
    -- Password: password123
    INSERT INTO users (
        id, email, password_hash, full_name, role_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'hr@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'HR Administrator',
        hr_role_id,
        CURRENT_DATE,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- Insert Auditor 1 user
    -- Can oversee all operations
    -- Email: auditor1@acemarket.com
    -- Password: password123
    INSERT INTO users (
        id, email, password_hash, full_name, role_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'auditor1@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Oluwaseun Adeyemi',
        auditor_role_id,
        CURRENT_DATE,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- Insert Auditor 2 user
    -- Can oversee all operations
    -- Email: auditor2@acemarket.com
    -- Password: password123
    INSERT INTO users (
        id, email, password_hash, full_name, role_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'auditor2@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Funmilayo Okafor',
        auditor_role_id,
        CURRENT_DATE,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    RAISE NOTICE '✅ Senior Admin users created successfully!';
    RAISE NOTICE '';
    RAISE NOTICE 'Login Credentials (All passwords: password123):';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '👔 CEO (also Chairman): ceo@acemarket.com';
    RAISE NOTICE '👔 COO:                  coo@acemarket.com';
    RAISE NOTICE '👔 HR Manager:           hr@acemarket.com';
    RAISE NOTICE '👔 Auditor 1:            auditor1@acemarket.com';
    RAISE NOTICE '👔 Auditor 2:            auditor2@acemarket.com';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '';
    RAISE NOTICE '🔐 Oversight Capabilities:';
    RAISE NOTICE '   ✓ CEO: Full company oversight, strategic decisions';
    RAISE NOTICE '   ✓ COO: Operations oversight, all branches and departments';
    RAISE NOTICE '   ✓ HR: Create accounts, manage staff, oversee all personnel';
    RAISE NOTICE '   ✓ Auditors: Financial and operational oversight, compliance';
    RAISE NOTICE '';
    RAISE NOTICE '📝 HR Exclusive Powers:';
    RAISE NOTICE '   ✓ Create new staff accounts for all roles';
    RAISE NOTICE '   ✓ Edit staff profiles and documents';
    RAISE NOTICE '   ✓ Upload/update/delete documents';
    RAISE NOTICE '';
END $$;
