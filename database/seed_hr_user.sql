-- Seed HR User for Ace Mall Staff Management System
-- This creates a default HR user for testing

-- Get the HR role ID
DO $$
DECLARE
    hr_role_id UUID;
BEGIN
    -- Get HR role ID
    SELECT id INTO hr_role_id FROM roles WHERE name = 'Human Resource' LIMIT 1;
    
    -- Insert HR user
    -- Email: hr@acemarket.com
    -- Password: password123
    -- Password hash generated with bcrypt cost 10
    INSERT INTO users (
        id,
        email,
        password_hash,
        full_name,
        role_id,
        date_joined,
        is_active,
        created_at,
        updated_at
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
    
    RAISE NOTICE 'HR user created successfully!';
    RAISE NOTICE 'Email: hr@acemarket.com';
    RAISE NOTICE 'Password: password123';
END $$;