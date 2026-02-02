-- ============================================
-- CLEANUP ALL DUMMY STAFF DATA
-- Preserves ONLY the master HR account
-- Email: hr@acesupermarket.com
-- ============================================

-- Start transaction for safety
BEGIN;

-- 1. Delete guarantor documents
DELETE FROM guarantor_documents;

-- 2. Delete guarantors
DELETE FROM guarantors;

-- 3. Delete next of kin
DELETE FROM next_of_kin;

-- 4. Delete work experience
DELETE FROM work_experience;

-- 5. Delete qualifications
DELETE FROM qualifications;

-- 6. Delete reviews
DELETE FROM reviews;

-- 7. Delete roster assignments
DELETE FROM roster_assignments;

-- 8. Delete rosters
DELETE FROM rosters;

-- 9. Delete shift templates
DELETE FROM shift_templates;

-- 10. Delete notifications
DELETE FROM notifications;

-- 11. Delete device tokens
DELETE FROM device_tokens;

-- 12. Delete document access logs
DELETE FROM document_access_logs;

-- 13. Delete promotion history
DELETE FROM promotion_history;

-- 14. Delete departed/terminated staff
DELETE FROM departed_staff;
DELETE FROM terminated_staff;

-- 15. Delete user hierarchy (manager relationships)
DELETE FROM user_hierarchy WHERE user_id IN (
    SELECT id FROM users WHERE email != 'hr@acesupermarket.com'
);

-- 16. Delete ALL users EXCEPT master HR
DELETE FROM users WHERE email != 'hr@acesupermarket.com';

-- 17. Delete temporary signups
DELETE FROM temp_signups;

-- Commit all changes
COMMIT;

-- ============================================
-- VERIFICATION - Check what remains
-- ============================================

\echo '✅ Cleanup Complete! Remaining records:'
\echo ''

SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'guarantors', COUNT(*) FROM guarantors
UNION ALL
SELECT 'next_of_kin', COUNT(*) FROM next_of_kin
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'rosters', COUNT(*) FROM rosters
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications;

\echo ''
\echo '📋 Remaining user:'
SELECT email, full_name, employee_id, is_active 
FROM users 
WHERE email = 'hr@acesupermarket.com';

\echo ''
\echo '✅ Database is now clean and ready for real staff uploads!'
\echo '🔐 Master HR Login: hr@acesupermarket.com / password123'
