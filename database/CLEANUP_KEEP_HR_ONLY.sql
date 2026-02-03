-- ==========================================
-- CLEANUP ALL STAFF - KEEP ONLY HR ACCOUNT
-- ==========================================
-- This script removes all staff data except hr@acesupermarket.com
-- Run this to start fresh with production data

BEGIN;

-- Store HR account ID for reference
DO $$
DECLARE
    hr_id UUID;
BEGIN
    -- Get HR account ID
    SELECT id INTO hr_id FROM users WHERE email = 'hr@acesupermarket.com';
    
    IF hr_id IS NULL THEN
        RAISE EXCEPTION 'HR account not found! Cannot proceed with cleanup.';
    END IF;
    
    RAISE NOTICE 'HR Account ID: %', hr_id;
    RAISE NOTICE 'Starting cleanup - preserving HR account only...';
    
    -- Delete all related data for users except HR
    
    -- 1. Delete notifications
    DELETE FROM notifications WHERE user_id != hr_id;
    RAISE NOTICE 'Deleted notifications';
    
    -- 2. Delete roster assignments
    DELETE FROM roster_assignments WHERE staff_id != hr_id;
    RAISE NOTICE 'Deleted roster assignments';
    
    -- 3. Delete rosters (HR doesn't create rosters)
    DELETE FROM rosters;
    RAISE NOTICE 'Deleted rosters';
    
    -- 4. Delete weekly reviews
    DELETE FROM weekly_reviews WHERE staff_id != hr_id OR reviewer_id != hr_id;
    RAISE NOTICE 'Deleted weekly reviews';
    
    -- 5. Delete promotion history
    DELETE FROM promotion_history WHERE user_id != hr_id;
    RAISE NOTICE 'Deleted promotion history';
    
    -- 6. Delete shift templates
    DELETE FROM shift_templates;
    RAISE NOTICE 'Deleted shift templates';
    
    -- 7. Delete device tokens
    DELETE FROM device_tokens WHERE user_id != hr_id;
    RAISE NOTICE 'Deleted device tokens';
    
    -- 8. Delete messages
    DELETE FROM messages WHERE user_id != hr_id;
    RAISE NOTICE 'Deleted messages';
    
    -- 9. Delete document access logs
    DELETE FROM document_access_logs WHERE user_id != hr_id OR accessed_by != hr_id;
    RAISE NOTICE 'Deleted document access logs';
    
    -- 10. Delete work experience
    DELETE FROM work_experience WHERE user_id != hr_id;
    RAISE NOTICE 'Deleted work experience';
    
    -- 11. Delete guarantor documents
    DELETE FROM guarantor_documents 
    WHERE guarantor_id IN (
        SELECT id FROM guarantors WHERE user_id != hr_id
    );
    RAISE NOTICE 'Deleted guarantor documents';
    
    -- 12. Delete guarantors
    DELETE FROM guarantors WHERE user_id != hr_id;
    RAISE NOTICE 'Deleted guarantors';
    
    -- 13. Delete next of kin
    DELETE FROM next_of_kin WHERE user_id != hr_id;
    RAISE NOTICE 'Deleted next of kin';
    
    -- 14. Delete terminated staff records
    DELETE FROM terminated_staff WHERE user_id != hr_id;
    RAISE NOTICE 'Deleted terminated staff records';
    
    -- 15. Delete password reset OTPs
    DELETE FROM password_reset_otps WHERE user_id != hr_id;
    RAISE NOTICE 'Deleted password reset OTPs';
    
    -- 16. Finally, delete all users except HR
    DELETE FROM users WHERE id != hr_id;
    RAISE NOTICE 'Deleted all users except HR';
    
    -- 17. Update HR password to "password123"
    UPDATE users 
    SET password_hash = '$2a$10$rFqYVz5Q8N3xGX.xJ0QXxO5kGnZKz0vXQp6qYqH8xQZ5pQnH8Z5Oa',
        updated_at = CURRENT_TIMESTAMP
    WHERE id = hr_id;
    RAISE NOTICE 'Updated HR password to: password123';
    
    RAISE NOTICE '✅ Cleanup completed successfully!';
    RAISE NOTICE 'Remaining account: hr@acesupermarket.com (password: password123)';
END $$;

COMMIT;

-- Verify cleanup
SELECT 
    'Users' as table_name,
    COUNT(*) as count,
    STRING_AGG(email, ', ') as remaining_emails
FROM users
UNION ALL
SELECT 
    'Next of Kin' as table_name,
    COUNT(*) as count,
    NULL as remaining_emails
FROM next_of_kin
UNION ALL
SELECT 
    'Guarantors' as table_name,
    COUNT(*) as count,
    NULL as remaining_emails
FROM guarantors
UNION ALL
SELECT 
    'Work Experience' as table_name,
    COUNT(*) as count,
    NULL as remaining_emails
FROM work_experience
UNION ALL
SELECT 
    'Rosters' as table_name,
    COUNT(*) as count,
    NULL as remaining_emails
FROM rosters
UNION ALL
SELECT 
    'Notifications' as table_name,
    COUNT(*) as count,
    NULL as remaining_emails
FROM notifications;
