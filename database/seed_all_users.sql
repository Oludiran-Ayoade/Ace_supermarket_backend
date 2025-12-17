-- Seed Users for All Hierarchies in Ace Mall Staff Management System
-- Password for ALL accounts: password123
-- Password hash: $2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP

DO $$
DECLARE
    -- Role IDs
    ceo_role_id UUID;
    chairman_role_id UUID;
    hr_role_id UUID;
    branch_mgr_role_id UUID;
    floor_mgr_role_id UUID;
    cashier_role_id UUID;
    cook_role_id UUID;
    bartender_role_id UUID;
    security_role_id UUID;
    
    -- Branch IDs
    ogbomosho_branch_id UUID;
    bodija_branch_id UUID;
    akobo_branch_id UUID;
    
    -- Department IDs
    supermarket_dept_id UUID;
    lounge_dept_id UUID;
    arcade_dept_id UUID;
    
    -- User IDs for managers
    floor_mgr_user_id UUID;
BEGIN
    -- Get Role IDs
    SELECT id INTO ceo_role_id FROM roles WHERE name = 'Chief Executive Officer (CEO)' LIMIT 1;
    SELECT id INTO chairman_role_id FROM roles WHERE name = 'Chairman' LIMIT 1;
    SELECT id INTO hr_role_id FROM roles WHERE name = 'Human Resource' LIMIT 1;
    SELECT id INTO branch_mgr_role_id FROM roles WHERE name = 'Branch Manager' LIMIT 1;
    SELECT id INTO floor_mgr_role_id FROM roles WHERE name = 'Floor Manager' LIMIT 1;
    SELECT id INTO cashier_role_id FROM roles WHERE name = 'Cashier' LIMIT 1;
    SELECT id INTO cook_role_id FROM roles WHERE name = 'Cook' LIMIT 1;
    SELECT id INTO bartender_role_id FROM roles WHERE name = 'Bartender' LIMIT 1;
    SELECT id INTO security_role_id FROM roles WHERE name = 'Security Guard' LIMIT 1;
    
    -- Get Branch IDs
    SELECT id INTO ogbomosho_branch_id FROM branches WHERE name = 'Ace Ogbomosho' LIMIT 1;
    SELECT id INTO bodija_branch_id FROM branches WHERE name = 'Ace Bodija' LIMIT 1;
    SELECT id INTO akobo_branch_id FROM branches WHERE name = 'Ace Akobo' LIMIT 1;
    
    -- Get Department IDs
    SELECT id INTO supermarket_dept_id FROM departments WHERE name = 'SuperMarket' LIMIT 1;
    SELECT id INTO lounge_dept_id FROM departments WHERE name = 'Lounge' LIMIT 1;
    SELECT id INTO arcade_dept_id FROM departments WHERE name = 'Fun & Arcade' LIMIT 1;
    
    -- ==========================================
    -- SENIOR ADMIN STAFF (No Branch/Department)
    -- ==========================================
    
    -- 1. CEO
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, 
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'ceo@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'John Adeyemi (CEO)',
        ceo_role_id,
        CURRENT_DATE - INTERVAL '2 years',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 2. Chairman
    INSERT INTO users (
        id, email, password_hash, full_name, role_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'chairman@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Chief Oluwaseun Ogunleye',
        chairman_role_id,
        CURRENT_DATE - INTERVAL '3 years',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 3. HR
    INSERT INTO users (
        id, email, password_hash, full_name, role_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'hr@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Mrs. Funmilayo Adebayo (HR)',
        hr_role_id,
        CURRENT_DATE - INTERVAL '1 year',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- ==========================================
    -- BRANCH MANAGERS
    -- ==========================================
    
    -- 4. Branch Manager - Ogbomosho
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'bm.ogbomosho@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Mr. Tunde Bakare',
        branch_mgr_role_id,
        ogbomosho_branch_id,
        CURRENT_DATE - INTERVAL '18 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 5. Branch Manager - Bodija
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'bm.bodija@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Mrs. Blessing Okonkwo',
        branch_mgr_role_id,
        bodija_branch_id,
        CURRENT_DATE - INTERVAL '14 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 6. Branch Manager - Akobo
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'bm.akobo@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Mr. Ibrahim Yusuf',
        branch_mgr_role_id,
        akobo_branch_id,
        CURRENT_DATE - INTERVAL '10 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- ==========================================
    -- FLOOR MANAGERS
    -- ==========================================
    
    -- 7. Floor Manager - Supermarket (Ogbomosho)
    floor_mgr_user_id := uuid_generate_v4();
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        floor_mgr_user_id,
        'fm.supermarket.ogbomosho@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Mr. Adebayo Fashola',
        floor_mgr_role_id,
        ogbomosho_branch_id,
        supermarket_dept_id,
        CURRENT_DATE - INTERVAL '8 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 8. Floor Manager - Lounge (Bodija)
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'fm.lounge.bodija@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Mrs. Sarah Ogundimu',
        floor_mgr_role_id,
        bodija_branch_id,
        lounge_dept_id,
        CURRENT_DATE - INTERVAL '6 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 9. Floor Manager - Arcade (Akobo)
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'fm.arcade.akobo@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Mr. Chukwudi Eze',
        floor_mgr_role_id,
        akobo_branch_id,
        arcade_dept_id,
        CURRENT_DATE - INTERVAL '5 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- ==========================================
    -- GENERAL STAFF
    -- ==========================================
    
    -- 10. Cashier - Supermarket (Ogbomosho)
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id, manager_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'cashier.supermarket.ogbomosho@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Biodun Alabi',
        cashier_role_id,
        ogbomosho_branch_id,
        supermarket_dept_id,
        floor_mgr_user_id,
        CURRENT_DATE - INTERVAL '4 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 11. Cook - Lounge (Bodija)
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'cook.lounge.bodija@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Chioma Nwankwo',
        cook_role_id,
        bodija_branch_id,
        lounge_dept_id,
        CURRENT_DATE - INTERVAL '3 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 12. Bartender - Lounge (Bodija)
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'bartender.lounge.bodija@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Emeka Okafor',
        bartender_role_id,
        bodija_branch_id,
        lounge_dept_id,
        CURRENT_DATE - INTERVAL '2 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 13. Security Guard - Akobo
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'security.akobo@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Musa Abdullahi',
        security_role_id,
        akobo_branch_id,
        CURRENT_DATE - INTERVAL '1 month',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'All users created successfully!';
    RAISE NOTICE 'Password for ALL accounts: password123';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'SENIOR ADMIN STAFF:';
    RAISE NOTICE '1. CEO: ceo@acemarket.com';
    RAISE NOTICE '2. Chairman: chairman@acemarket.com';
    RAISE NOTICE '3. HR: hr@acemarket.com';
    RAISE NOTICE '';
    RAISE NOTICE 'BRANCH MANAGERS:';
    RAISE NOTICE '4. Ogbomosho: bm.ogbomosho@acemarket.com';
    RAISE NOTICE '5. Bodija: bm.bodija@acemarket.com';
    RAISE NOTICE '6. Akobo: bm.akobo@acemarket.com';
    RAISE NOTICE '';
    RAISE NOTICE 'FLOOR MANAGERS:';
    RAISE NOTICE '7. Supermarket (Ogbomosho): fm.supermarket.ogbomosho@acemarket.com';
    RAISE NOTICE '8. Lounge (Bodija): fm.lounge.bodija@acemarket.com';
    RAISE NOTICE '9. Arcade (Akobo): fm.arcade.akobo@acemarket.com';
    RAISE NOTICE '';
    RAISE NOTICE 'GENERAL STAFF:';
    RAISE NOTICE '10. Cashier: cashier.supermarket.ogbomosho@acemarket.com';
    RAISE NOTICE '11. Cook: cook.lounge.bodija@acemarket.com';
    RAISE NOTICE '12. Bartender: bartender.lounge.bodija@acemarket.com';
    RAISE NOTICE '13. Security: security.akobo@acemarket.com';
    RAISE NOTICE '========================================';
END $$;
