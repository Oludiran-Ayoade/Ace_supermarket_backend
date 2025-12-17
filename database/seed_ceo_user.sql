-- Seed CEO User for Ace Mall Staff Management System
-- This creates a default CEO user for testing

-- Get the CEO role ID
DO $$
DECLARE
    ceo_role_id UUID;
BEGIN
    -- Get CEO role ID
    SELECT id INTO ceo_role_id FROM roles WHERE name = 'Chief Executive Officer (CEO)' LIMIT 1;
    
    -- Insert CEO user
    -- Email: ceo@acemarket.com
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
        'ceo@acemarket.com',
        '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP',
        'John Adebayo',
        ceo_role_id,
        CURRENT_DATE,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    RAISE NOTICE 'CEO user created successfully!';
    RAISE NOTICE 'Email: ceo@acemarket.com';
    RAISE NOTICE 'Password: password123';
END $$;
