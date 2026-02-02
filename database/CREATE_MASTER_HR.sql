-- ============================================
-- CREATE MASTER HR ACCOUNT
-- This account will survive cleanup operations
-- Email: hr@acesupermarket.com
-- Password: AceHR2024!
-- ============================================

-- First, get the HR role ID
DO $$
DECLARE
    hr_role_id UUID;
BEGIN
    -- Get Human Resource role ID
    SELECT id INTO hr_role_id FROM roles WHERE name = 'Human Resource' LIMIT 1;
    
    IF hr_role_id IS NULL THEN
        RAISE EXCEPTION 'Human Resource role not found in database';
    END IF;

    -- Delete existing master HR if exists (for re-runs)
    DELETE FROM users WHERE email = 'hr@acesupermarket.com';

    -- Create master HR account
    -- Password: AceHR2024! (bcrypt hashed)
    INSERT INTO users (
        id,
        email,
        password,
        full_name,
        role_id,
        employee_id,
        is_active,
        is_email_verified,
        created_at,
        updated_at
    ) VALUES (
        gen_random_uuid(),
        'hr@acesupermarket.com',
        '$2a$10$rX5YZqK5F9vPJ.nW6qRJxuYt.KJHW4Z8W0qXK9vZH8mY1iKjF7N8u', -- AceHR2024!
        'Master HR Administrator',
        hr_role_id,
        'HR-MASTER-001',
        true,
        true,
        NOW(),
        NOW()
    );

    RAISE NOTICE '✅ Master HR account created successfully';
    RAISE NOTICE 'Email: hr@acesupermarket.com';
    RAISE NOTICE 'Password: AceHR2024!';
    RAISE NOTICE 'This account will NOT be deleted during cleanup operations';
END $$;
