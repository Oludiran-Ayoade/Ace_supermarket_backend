-- ============================================
-- CLEAR ALL DUMMY DATA - Ace Supermarket
-- ============================================
-- This script removes ALL test/dummy data from the database
-- Use this before deploying to production or when ready for real employee data
-- ============================================

BEGIN;

-- Step 1: Clear all user-related data
DELETE FROM roster_assignments;
DELETE FROM rosters;
DELETE FROM reviews;
DELETE FROM notifications;
DELETE FROM shift_templates;
DELETE FROM work_experience;
DELETE FROM qualifications;
DELETE FROM promotion_history;
DELETE FROM salary_history;

-- Step 2: Clear all users (this will cascade to related tables)
DELETE FROM users;

-- Step 3: Clear temporary signup data
DELETE FROM temp_signups;

-- Step 4: Reset sequences (if any)
-- Add any sequence resets here if needed

-- Step 5: Verify cleanup
DO $$
DECLARE
    user_count INTEGER;
    roster_count INTEGER;
    review_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM users;
    SELECT COUNT(*) INTO roster_count FROM rosters;
    SELECT COUNT(*) INTO review_count FROM reviews;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CLEANUP COMPLETE';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Remaining users: %', user_count;
    RAISE NOTICE 'Remaining rosters: %', roster_count;
    RAISE NOTICE 'Remaining reviews: %', review_count;
    RAISE NOTICE '========================================';
    
    IF user_count = 0 THEN
        RAISE NOTICE '✅ All dummy data cleared successfully!';
    ELSE
        RAISE WARNING '⚠️  Some data remains. Please check.';
    END IF;
END $$;

COMMIT;

-- ============================================
-- NOTES:
-- ============================================
-- This script does NOT delete:
-- - Branches (keep the 6 branch locations)
-- - Departments (keep the 6 departments)
-- - Roles (keep all role definitions)
-- - Sub-departments (keep Cinema, Saloon, etc.)
--
-- After running this script, you can:
-- 1. Have HR create real employee accounts
-- 2. Employees can sign in with their credentials
-- 3. Start fresh with production data
-- ============================================
