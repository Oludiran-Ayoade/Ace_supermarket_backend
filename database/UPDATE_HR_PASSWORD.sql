-- Update HR password to "password123"
-- This uses a properly generated bcrypt hash

UPDATE users 
SET password_hash = '$2a$10$pPoNePPG.iBje.UgUCH4CeG9byd7LmzN0IhV6mqKIWeWoz/AqBAt2',
    updated_at = CURRENT_TIMESTAMP
WHERE email = 'hr@acesupermarket.com';

-- Verify the update
SELECT 
    email,
    full_name,
    role_id,
    is_active,
    created_at,
    'Password updated to: password123' as note
FROM users 
WHERE email = 'hr@acesupermarket.com';
