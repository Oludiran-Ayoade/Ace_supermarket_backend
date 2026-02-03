-- Simple cleanup - Delete all users except hr@acesupermarket.com
-- This deletes related records first, then users

-- 1. Delete all guarantor documents
DELETE FROM guarantor_documents 
WHERE guarantor_id IN (
    SELECT g.id FROM guarantors g
    JOIN users u ON g.user_id = u.id
    WHERE u.email != 'hr@acesupermarket.com'
);

-- 2. Delete all guarantors
DELETE FROM guarantors 
WHERE user_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 3. Delete all next of kin
DELETE FROM next_of_kin 
WHERE user_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 4. Delete all work experience
DELETE FROM work_experience 
WHERE user_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 5. Delete all notifications
DELETE FROM notifications 
WHERE user_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 6. Delete all roster assignments
DELETE FROM roster_assignments 
WHERE staff_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 7. Delete all rosters
DELETE FROM rosters;

-- 8. Delete all weekly reviews
DELETE FROM weekly_reviews 
WHERE staff_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
) OR reviewer_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 9. Delete all promotion history
DELETE FROM promotion_history 
WHERE user_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 10. Delete all shift templates
DELETE FROM shift_templates;

-- 11. Delete all device tokens
DELETE FROM device_tokens 
WHERE user_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 12. Delete all messages
DELETE FROM messages 
WHERE user_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 13. Delete all document access logs
DELETE FROM document_access_logs 
WHERE user_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
) OR accessed_by IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 14. Delete all terminated staff records
DELETE FROM terminated_staff 
WHERE user_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 15. Delete all password reset OTPs
DELETE FROM password_reset_otps 
WHERE user_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 16. Delete all users except HR
DELETE FROM users WHERE email != 'hr@acesupermarket.com';

-- 17. Update HR password to password123
UPDATE users 
SET password_hash = '$2a$10$pPoNePPG.iBje.UgUCH4CeG9byd7LmzN0IhV6mqKIWeWoz/AqBAt2',
    updated_at = CURRENT_TIMESTAMP
WHERE email = 'hr@acesupermarket.com';

-- Verify results
SELECT 
    'Users' as table_name,
    COUNT(*) as count,
    STRING_AGG(email, ', ') as emails
FROM users
UNION ALL
SELECT 'Next of Kin', COUNT(*), NULL FROM next_of_kin
UNION ALL
SELECT 'Guarantors', COUNT(*), NULL FROM guarantors
UNION ALL
SELECT 'Work Experience', COUNT(*), NULL FROM work_experience
UNION ALL
SELECT 'Rosters', COUNT(*), NULL FROM rosters
UNION ALL
SELECT 'Notifications', COUNT(*), NULL FROM notifications;
