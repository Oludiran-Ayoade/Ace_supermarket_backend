-- Fix NULL department assignments for all staff
-- This ensures every staff member has a department assigned

DO $$
DECLARE
    supermarket_dept_id UUID;
    lounge_dept_id UUID;
    arcade_dept_id UUID;
    cinema_dept_id UUID;
    saloon_dept_id UUID;
    bakery_dept_id UUID;
BEGIN
    -- Get department IDs
    SELECT id INTO supermarket_dept_id FROM departments WHERE name = 'SuperMarket' LIMIT 1;
    SELECT id INTO lounge_dept_id FROM departments WHERE name = 'Lounge' LIMIT 1;
    SELECT id INTO arcade_dept_id FROM departments WHERE name = 'Fun & Arcade' LIMIT 1;
    SELECT id INTO cinema_dept_id FROM departments WHERE name = 'Cinema' LIMIT 1;
    SELECT id INTO saloon_dept_id FROM departments WHERE name = 'Saloon' LIMIT 1;
    SELECT id INTO bakery_dept_id FROM departments WHERE name = 'Bakery' LIMIT 1;

    RAISE NOTICE '🔧 Fixing NULL department assignments...';
    
    -- Assign Branch Managers to SuperMarket department (main operations)
    UPDATE users 
    SET department_id = supermarket_dept_id
    WHERE department_id IS NULL 
    AND role_id IN (SELECT id FROM roles WHERE name LIKE '%Branch Manager%')
    AND branch_id IS NOT NULL;
    
    RAISE NOTICE '✅ Branch Managers assigned to SuperMarket department';
    
    -- Assign CEO, COO, HR, Auditors to SuperMarket (corporate/admin department)
    UPDATE users 
    SET department_id = supermarket_dept_id
    WHERE department_id IS NULL 
    AND role_id IN (
        SELECT id FROM roles 
        WHERE name IN ('CEO', 'Chief Executive Officer', 'COO', 'Chief Operating Officer', 
                       'HR', 'HR Manager', 'Human Resource', 'Auditor')
    );
    
    RAISE NOTICE '✅ Senior admin staff assigned to SuperMarket department';
    
    -- Assign any remaining NULL departments to SuperMarket as default
    UPDATE users 
    SET department_id = supermarket_dept_id
    WHERE department_id IS NULL 
    AND branch_id IS NOT NULL;
    
    RAISE NOTICE '✅ Remaining staff assigned to SuperMarket department';
    
    -- Report results
    RAISE NOTICE '';
    RAISE NOTICE '📊 Department Assignment Summary:';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    
    -- Count staff per department
    FOR dept_name, staff_count IN 
        SELECT d.name, COUNT(u.id)
        FROM departments d
        LEFT JOIN users u ON d.id = u.department_id
        GROUP BY d.name
        ORDER BY COUNT(u.id) DESC
    LOOP
        RAISE NOTICE '   % staff in %', staff_count, dept_name;
    END LOOP;
    
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    
    -- Check if any NULL departments remain
    IF EXISTS (SELECT 1 FROM users WHERE department_id IS NULL AND branch_id IS NOT NULL) THEN
        RAISE WARNING '⚠️  Some staff still have NULL departments!';
    ELSE
        RAISE NOTICE '✅ All staff now have department assignments!';
    END IF;
    
    RAISE NOTICE '';
    
END $$;
