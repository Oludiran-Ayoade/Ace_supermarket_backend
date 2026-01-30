-- Migration: Update Fun & Arcade department roles
-- Changes managers to supervisors for Cinema, Photo Studio, Saloon, and Casino
-- Adds Supervisor (Arcade) role

DO $$ 
DECLARE
    fun_arcade_dept_id UUID;
    cinema_subdept_id UUID;
    photo_subdept_id UUID;
    saloon_subdept_id UUID;
    arcade_subdept_id UUID;
    casino_subdept_id UUID;
BEGIN
    -- Get department ID
    SELECT id INTO fun_arcade_dept_id FROM departments WHERE name = 'Fun & Arcade';
    
    -- Get sub-department IDs
    SELECT id INTO cinema_subdept_id FROM sub_departments WHERE name = 'Cinema' AND parent_department_id = fun_arcade_dept_id;
    SELECT id INTO photo_subdept_id FROM sub_departments WHERE name = 'Photo Studio' AND parent_department_id = fun_arcade_dept_id;
    SELECT id INTO saloon_subdept_id FROM sub_departments WHERE name = 'Saloon' AND parent_department_id = fun_arcade_dept_id;
    SELECT id INTO arcade_subdept_id FROM sub_departments WHERE name = 'Arcade and Kiddies Park' AND parent_department_id = fun_arcade_dept_id;
    SELECT id INTO casino_subdept_id FROM sub_departments WHERE name = 'Casino' AND parent_department_id = fun_arcade_dept_id;

    -- Update Cinema: Manager → Supervisor
    UPDATE roles 
    SET name = 'Supervisor (Cinema)', 
        description = 'Supervises Cinema operations'
    WHERE name = 'Manager (Cinema)' 
    AND department_id = fun_arcade_dept_id 
    AND sub_department_id = cinema_subdept_id;

    -- Update Photo Studio: Manager → Supervisor
    UPDATE roles 
    SET name = 'Supervisor (Photo Studio)', 
        description = 'Supervises Photo Studio operations'
    WHERE name = 'Manager (Photo Studio)' 
    AND department_id = fun_arcade_dept_id 
    AND sub_department_id = photo_subdept_id;

    -- Update Saloon: Manager → Supervisor
    UPDATE roles 
    SET name = 'Supervisor (Saloon)', 
        description = 'Supervises Saloon operations'
    WHERE name = 'Manager (Saloon)' 
    AND department_id = fun_arcade_dept_id 
    AND sub_department_id = saloon_subdept_id;

    -- Update Casino: Manager → Supervisor
    UPDATE roles 
    SET name = 'Supervisor (Casino)', 
        description = 'Supervises Casino operations'
    WHERE name = 'Manager (Casino)' 
    AND department_id = fun_arcade_dept_id 
    AND sub_department_id = casino_subdept_id;

    -- Add new Supervisor (Arcade) role if it doesn't exist
    INSERT INTO roles (name, category, department_id, sub_department_id, description) 
    VALUES ('Supervisor (Arcade)', 'admin', fun_arcade_dept_id, arcade_subdept_id, 'Supervises Arcade operations')
    ON CONFLICT (name, department_id) DO NOTHING;

    RAISE NOTICE '✅ Fun & Arcade roles updated successfully!';
END $$;

-- Verify the changes
SELECT r.name, r.category, d.name as department, sd.name as sub_department
FROM roles r
JOIN departments d ON r.department_id = d.id
LEFT JOIN sub_departments sd ON r.sub_department_id = sd.id
WHERE d.name = 'Fun & Arcade' AND r.category = 'admin'
ORDER BY sd.name, r.name;
