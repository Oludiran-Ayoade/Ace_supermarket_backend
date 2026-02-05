-- Add Marketing Department, Other Staffs Department, and Senior Staffs department
-- Migration for new departments and roles

-- ============================================
-- ADD NEW DEPARTMENTS
-- ============================================

-- Senior Staffs Department (for top-level senior executives)
INSERT INTO departments (id, name, description, is_active)
VALUES (
    uuid_generate_v4(),
    'Senior Staffs',
    'Top-level senior executives and management',
    true
) ON CONFLICT (name) DO NOTHING;

-- Marketing Department
INSERT INTO departments (id, name, description, is_active)
VALUES (
    uuid_generate_v4(),
    'Marketing',
    'Marketing and promotional activities',
    true
) ON CONFLICT (name) DO NOTHING;

-- Other Staffs Department (for staff not attached to specific departments)
INSERT INTO departments (id, name, description, is_active)
VALUES (
    uuid_generate_v4(),
    'Other Staffs',
    'Staff not attached to specific departments',
    true
) ON CONFLICT (name) DO NOTHING;

-- ============================================
-- MARKETING DEPARTMENT ROLES
-- ============================================

-- Marketing Group Head (Admin level)
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Marketing Group Head', 'admin', id, 'Head of marketing department across all branches'
FROM departments WHERE name = 'Marketing'
ON CONFLICT (name, department_id) DO NOTHING;

-- Marketing Staffs (General level)
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Marketing Staff', 'general', id, 'Marketing department general staff'
FROM departments WHERE name = 'Marketing'
ON CONFLICT (name, department_id) DO NOTHING;

-- ============================================
-- OTHER STAFFS DEPARTMENT ROLES
-- ============================================

-- Social Media Manager (Admin level)
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Social Media Manager', 'admin', id, 'Manages social media presence and online marketing'
FROM departments WHERE name = 'Other Staffs'
ON CONFLICT (name, department_id) DO NOTHING;

-- Graphic Designer (General level)
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Graphic Designer', 'general', id, 'Creates visual content and designs'
FROM departments WHERE name = 'Other Staffs'
ON CONFLICT (name, department_id) DO NOTHING;

-- ============================================
-- NEW SENIOR ADMIN ROLE
-- ============================================

-- Hospitality Unit (HS Auditor) - Senior role (no department)
INSERT INTO roles (name, category, description) 
VALUES ('Hospitality Unit (HS Auditor)', 'senior_admin', 'Senior hospitality auditor role')
ON CONFLICT (name, department_id) DO NOTHING;

-- ============================================
-- UPDATE ROLE CATEGORIES (Add "Senior Staffs" category)
-- ============================================
-- Note: The category field already supports 'senior_admin', 'admin', 'general'
-- The "Senior Staffs" is essentially the 'senior_admin' category
-- But we'll document it here for clarity

-- Senior Staffs category includes:
-- 1. Chief Executive Officer (CEO)
-- 2. Chief Operating Officer (COO)
-- 3. Human Resource (HR)
-- 4. Auditor
-- 5. Hospitality Unit (HS Auditor) [NEW]

COMMENT ON COLUMN roles.category IS 'Staff category: senior_admin (Senior Staffs), admin (Admin Officers), general (General Staff)';
