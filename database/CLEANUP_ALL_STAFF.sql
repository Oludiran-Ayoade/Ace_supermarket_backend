-- ============================================
-- CLEANUP ALL DUMMY STAFF DATA
-- This script removes all staff and related data
-- to prepare for real staff uploads
-- ============================================

BEGIN;

-- 1. Delete guarantor documents (foreign key to guarantors)
DELETE FROM guarantor_documents 
WHERE guarantor_id IN (
    SELECT id FROM guarantors
);
COMMIT;

BEGIN;
-- 2. Delete guarantors
DELETE FROM guarantors;
COMMIT;

BEGIN;
-- 3. Delete next of kin
DELETE FROM next_of_kin;
COMMIT;

BEGIN;
-- 4. Delete work experience
DELETE FROM work_experience;
COMMIT;

BEGIN;
-- 5. Delete qualifications
DELETE FROM qualifications;
COMMIT;

BEGIN;
-- 6. Delete reviews
DELETE FROM reviews;
COMMIT;

BEGIN;
-- 7. Delete roster assignments
DELETE FROM roster_assignments;
COMMIT;

BEGIN;
-- 8. Delete rosters
DELETE FROM rosters;
COMMIT;

BEGIN;
-- 9. Delete shift templates
DELETE FROM shift_templates;
COMMIT;

BEGIN;
-- 10. Delete notifications
DELETE FROM notifications;
COMMIT;

BEGIN;
-- 11. Delete device tokens
DELETE FROM device_tokens;
COMMIT;

BEGIN;
-- 12. Delete document access logs
DELETE FROM document_access_logs;
COMMIT;

BEGIN;
-- 13. Delete promotion history
DELETE FROM promotion_history;
COMMIT;

BEGIN;
-- 14. Delete terminated staff
DELETE FROM terminated_staff;
COMMIT;

BEGIN;
-- 15. Delete all users (staff)
DELETE FROM users;
COMMIT;

BEGIN;
-- 16. Delete temporary signups
DELETE FROM temp_signups;
COMMIT;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check remaining records
SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'guarantors', COUNT(*) FROM guarantors
UNION ALL
SELECT 'guarantor_documents', COUNT(*) FROM guarantor_documents
UNION ALL
SELECT 'next_of_kin', COUNT(*) FROM next_of_kin
UNION ALL
SELECT 'work_experience', COUNT(*) FROM work_experience
UNION ALL
SELECT 'qualifications', COUNT(*) FROM qualifications
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'rosters', COUNT(*) FROM rosters
UNION ALL
SELECT 'roster_assignments', COUNT(*) FROM roster_assignments
UNION ALL
SELECT 'shift_templates', COUNT(*) FROM shift_templates
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL
SELECT 'device_tokens', COUNT(*) FROM device_tokens
UNION ALL
SELECT 'document_access_logs', COUNT(*) FROM document_access_logs
UNION ALL
SELECT 'promotion_history', COUNT(*) FROM promotion_history
UNION ALL
SELECT 'terminated_staff', COUNT(*) FROM terminated_staff
UNION ALL
SELECT 'temp_signups', COUNT(*) FROM temp_signups;

-- ============================================
-- CLEANUP COMPLETE
-- Database is now ready for fresh staff uploads
-- ============================================
