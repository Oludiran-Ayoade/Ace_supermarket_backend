-- Quick test user for forgot password testing
-- Email: test@acesupermarket.com
-- Password: password

INSERT INTO users (
    id,
    email,
    password_hash,
    full_name,
    is_active,
    is_terminated,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    'test@acesupermarket.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'Test User',
    true,
    false,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
) ON CONFLICT (email) DO NOTHING;
