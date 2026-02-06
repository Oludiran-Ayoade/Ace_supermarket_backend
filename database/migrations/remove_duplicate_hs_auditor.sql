-- Remove duplicate Hospitality Unit (HS Auditor) role
-- Keep only one instance of this senior_admin role

-- First, check how many exist
-- SELECT id, name, category, department_id, created_at FROM roles WHERE name = 'Hospitality Unit (HS Auditor)';

-- Delete duplicates, keeping only the oldest one (earliest created_at)
DELETE FROM roles 
WHERE name = 'Hospitality Unit (HS Auditor)' 
AND id NOT IN (
    SELECT id 
    FROM roles 
    WHERE name = 'Hospitality Unit (HS Auditor)'
    ORDER BY created_at ASC
    LIMIT 1
);

-- Verify only one remains
-- SELECT id, name, category, department_id, created_at FROM roles WHERE name = 'Hospitality Unit (HS Auditor)';
