-- Seed Users for All Hierarchies in Ace Supermarket (Full Schema)
-- Password for ALL accounts: password123
-- Bcrypt hash: $2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP

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
    baker_role_id UUID;
    usher_role_id UUID;
    attendant_role_id UUID;
    
    -- Branch IDs
    ogbomosho_branch_id UUID;
    bodija_branch_id UUID;
    akobo_branch_id UUID;
    oluyole_branch_id UUID;
    oyo_branch_id UUID;
    
    -- Department IDs
    supermarket_dept_id UUID;
    lounge_dept_id UUID;
    arcade_dept_id UUID;
    bakery_dept_id UUID;
    cinema_dept_id UUID;
    
    -- User IDs for managers
    floor_mgr_supermarket_id UUID;
    floor_mgr_lounge_id UUID;
    floor_mgr_arcade_id UUID;
    floor_mgr_bakery_id UUID;
    floor_mgr_cinema_id UUID;
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
    SELECT id INTO baker_role_id FROM roles WHERE name = 'Baker' LIMIT 1;
    SELECT id INTO usher_role_id FROM roles WHERE name = 'Usher' LIMIT 1;
    SELECT id INTO attendant_role_id FROM roles WHERE name = 'Arcade Attendant' LIMIT 1;
    
    -- Get Branch IDs
    SELECT id INTO ogbomosho_branch_id FROM branches WHERE name LIKE '%Ogbomosho%' LIMIT 1;
    SELECT id INTO bodija_branch_id FROM branches WHERE name LIKE '%Bodija%' LIMIT 1;
    SELECT id INTO akobo_branch_id FROM branches WHERE name LIKE '%Akobo%' LIMIT 1;
    SELECT id INTO oluyole_branch_id FROM branches WHERE name LIKE '%Oluyole%' LIMIT 1;
    SELECT id INTO oyo_branch_id FROM branches WHERE name LIKE '%Oyo%' LIMIT 1;
    
    -- Get Department IDs
    SELECT id INTO supermarket_dept_id FROM departments WHERE name = 'SuperMarket' LIMIT 1;
    SELECT id INTO lounge_dept_id FROM departments WHERE name = 'Lounge' LIMIT 1;
    SELECT id INTO arcade_dept_id FROM departments WHERE name = 'Fun & Arcade' LIMIT 1;
    SELECT id INTO bakery_dept_id FROM departments WHERE name = 'Bakery' LIMIT 1;
    SELECT id INTO cinema_dept_id FROM departments WHERE name = 'Cinema' LIMIT 1;
    
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
        'John Adeyemi',
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
        'Mrs. Funmilayo Adebayo',
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
    
    -- 7. Branch Manager - Oluyole
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'bm.oluyole@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Mrs. Kemi Adeleke',
        branch_mgr_role_id,
        oluyole_branch_id,
        CURRENT_DATE - INTERVAL '12 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 8. Branch Manager - Oyo
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'bm.oyo@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Mr. Segun Ajayi',
        branch_mgr_role_id,
        oyo_branch_id,
        CURRENT_DATE - INTERVAL '8 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- ==========================================
    -- FLOOR MANAGERS
    -- ==========================================
    
    -- 9. Floor Manager - Supermarket (Ogbomosho)
    floor_mgr_supermarket_id := uuid_generate_v4();
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        floor_mgr_supermarket_id,
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
    
    -- 10. Floor Manager - Lounge (Bodija)
    floor_mgr_lounge_id := uuid_generate_v4();
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        floor_mgr_lounge_id,
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
    
    -- 11. Floor Manager - Arcade (Akobo)
    floor_mgr_arcade_id := uuid_generate_v4();
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        floor_mgr_arcade_id,
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
    
    -- 12. Floor Manager - Bakery (Oluyole)
    floor_mgr_bakery_id := uuid_generate_v4();
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        floor_mgr_bakery_id,
        'fm.bakery.oluyole@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Mrs. Ngozi Okeke',
        floor_mgr_role_id,
        oluyole_branch_id,
        bakery_dept_id,
        CURRENT_DATE - INTERVAL '7 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 13. Floor Manager - Cinema (Oyo)
    floor_mgr_cinema_id := uuid_generate_v4();
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        floor_mgr_cinema_id,
        'fm.cinema.oyo@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Mr. Yusuf Mohammed',
        floor_mgr_role_id,
        oyo_branch_id,
        cinema_dept_id,
        CURRENT_DATE - INTERVAL '4 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- ==========================================
    -- GENERAL STAFF
    -- ==========================================
    
    -- 14. Cashier - Supermarket (Ogbomosho)
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'cashier.ogbomosho@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Biodun Alabi',
        cashier_role_id,
        ogbomosho_branch_id,
        supermarket_dept_id,
        CURRENT_DATE - INTERVAL '4 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 15. Cook - Lounge (Bodija)
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'cook.bodija@acemarket.com',
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
    
    -- 16. Bartender - Lounge (Bodija)
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'bartender.bodija@acemarket.com',
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
    
    -- 17. Security Guard (Akobo)
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
    
    -- 18. Baker - Bakery (Oluyole)
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'baker.oluyole@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Fatima Bello',
        baker_role_id,
        oluyole_branch_id,
        bakery_dept_id,
        CURRENT_DATE - INTERVAL '5 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 19. Usher - Cinema (Oyo)
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'usher.oyo@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Tunde Adeyemi',
        usher_role_id,
        oyo_branch_id,
        cinema_dept_id,
        CURRENT_DATE - INTERVAL '3 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    -- 20. Arcade Attendant (Akobo)
    INSERT INTO users (
        id, email, password_hash, full_name, role_id, branch_id, department_id,
        date_joined, is_active, created_at, updated_at
    ) VALUES (
        uuid_generate_v4(),
        'attendant.akobo@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'Amaka Obi',
        attendant_role_id,
        akobo_branch_id,
        arcade_dept_id,
        CURRENT_DATE - INTERVAL '2 months',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'All users created successfully!';
    RAISE NOTICE 'Password for ALL accounts: password123';
    RAISE NOTICE '========================================';
END $$;
