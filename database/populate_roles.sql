-- Populate Complete Role Hierarchy for Ace Mall Staff Management
-- This script creates all roles according to the organizational structure

-- ============================================
-- SENIOR ADMIN OFFICERS (Category: senior_admin)
-- ============================================

INSERT INTO roles (name, category, description) VALUES
('Chief Executive Officer', 'senior_admin', 'CEO - Top executive officer overseeing all operations'),
('Chief Operating Officer', 'senior_admin', 'COO - Oversees daily operations across all branches'),
('Human Resource', 'senior_admin', 'HR - Manages all staff recruitment, profiles, and HR functions'),
('Auditor', 'senior_admin', 'Internal auditor for financial and operational compliance')
ON CONFLICT (name, department_id) DO NOTHING;

-- ============================================
-- ADMIN OFFICERS - GROUP HEADS (Category: admin)
-- ============================================

-- Get department IDs for group heads
DO $$ 
DECLARE
    supermarket_dept_id UUID;
    eatery_dept_id UUID;
    lounge_dept_id UUID;
    fun_arcade_dept_id UUID;
    compliance_dept_id UUID;
    facility_dept_id UUID;
BEGIN
    -- Get department IDs
    SELECT id INTO supermarket_dept_id FROM departments WHERE name = 'SuperMarket';
    SELECT id INTO eatery_dept_id FROM departments WHERE name = 'Eatery';
    SELECT id INTO lounge_dept_id FROM departments WHERE name = 'Lounge';
    SELECT id INTO fun_arcade_dept_id FROM departments WHERE name = 'Fun & Arcade';
    SELECT id INTO compliance_dept_id FROM departments WHERE name = 'Compliance';
    SELECT id INTO facility_dept_id FROM departments WHERE name = 'Facility Management';

    -- Group Heads (oversee department across all branches)
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Group Head (SuperMarket)', 'admin', supermarket_dept_id, 'Heads SuperMarket department across all 13 branches'),
    ('Group Head (Eatery)', 'admin', eatery_dept_id, 'Heads Eatery department across all 13 branches'),
    ('Group Head (Lounge)', 'admin', lounge_dept_id, 'Heads Lounge department across all 13 branches'),
    ('Group Head (Fun & Arcade)', 'admin', fun_arcade_dept_id, 'Heads Fun & Arcade department across all 13 branches'),
    ('Group Head (Compliance)', 'admin', compliance_dept_id, 'Heads Compliance department across all 13 branches'),
    ('Group Head (Facility Management)', 'admin', facility_dept_id, 'Heads Facility Management across all 13 branches')
    ON CONFLICT (name, department_id) DO NOTHING;

    -- ============================================
    -- SUPERMARKET DEPARTMENT ROLES
    -- ============================================
    
    -- SuperMarket Admin Officers
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Branch Manager (SuperMarket)', 'admin', supermarket_dept_id, 'Manages SuperMarket operations at branch level'),
    ('Operations Manager (SuperMarket)', 'admin', supermarket_dept_id, 'Oversees daily operations in SuperMarket'),
    ('Admin Officer (SuperMarket)', 'admin', supermarket_dept_id, 'Administrative support for SuperMarket')
    ON CONFLICT (name, department_id) DO NOTHING;

    -- SuperMarket Floor Manager
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Floor Manager (SuperMarket)', 'admin', supermarket_dept_id, 'Manages floor staff and creates rosters for SuperMarket')
    ON CONFLICT (name, department_id) DO NOTHING;

    -- SuperMarket General Staff
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Cashier (SuperMarket)', 'general', supermarket_dept_id, 'Handles customer transactions'),
    ('Baker (SuperMarket)', 'general', supermarket_dept_id, 'Prepares baked goods'),
    ('Customer Service Relations (SuperMarket)', 'general', supermarket_dept_id, 'Handles customer inquiries and support')
    ON CONFLICT (name, department_id) DO NOTHING;

    -- ============================================
    -- EATERY DEPARTMENT ROLES
    -- ============================================
    
    -- Eatery Admin Officers
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Branch Manager (Eatery)', 'admin', eatery_dept_id, 'Manages Eatery operations at branch level'),
    ('Supervisor (Eatery)', 'admin', eatery_dept_id, 'Supervises Eatery staff and operations'),
    ('Store Manager (Eatery)', 'admin', eatery_dept_id, 'Manages Eatery store inventory and supplies')
    ON CONFLICT (name, department_id) DO NOTHING;

    -- Eatery Floor Manager
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Floor Manager (Eatery)', 'admin', eatery_dept_id, 'Manages floor staff and creates rosters for Eatery')
    ON CONFLICT (name, department_id) DO NOTHING;

    -- Eatery General Staff
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Cashier (Eatery)', 'general', eatery_dept_id, 'Handles customer transactions'),
    ('Baker (Eatery)', 'general', eatery_dept_id, 'Prepares baked goods'),
    ('Cook (Eatery)', 'general', eatery_dept_id, 'Prepares meals and dishes'),
    ('Lobby Staff (Eatery)', 'general', eatery_dept_id, 'Manages lobby area and customer seating'),
    ('Kitchen Assistant (Eatery)', 'general', eatery_dept_id, 'Assists in kitchen operations')
    ON CONFLICT (name, department_id) DO NOTHING;

    -- ============================================
    -- LOUNGE DEPARTMENT ROLES
    -- ============================================
    
    -- Lounge Admin Officers
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Branch Manager (Lounge)', 'admin', lounge_dept_id, 'Manages Lounge operations at branch level'),
    ('Operations Manager (Lounge)', 'admin', lounge_dept_id, 'Oversees daily operations in Lounge'),
    ('Supervisor (Lounge)', 'admin', lounge_dept_id, 'Supervises Lounge staff and operations')
    ON CONFLICT (name, department_id) DO NOTHING;

    -- Lounge Floor Manager
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Floor Manager (Lounge)', 'admin', lounge_dept_id, 'Manages floor staff and creates rosters for Lounge')
    ON CONFLICT (name, department_id) DO NOTHING;

    -- Lounge General Staff
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Cashier (Lounge)', 'general', lounge_dept_id, 'Handles customer transactions'),
    ('Cook (Lounge)', 'general', lounge_dept_id, 'Prepares meals and dishes'),
    ('Bartender (Lounge)', 'general', lounge_dept_id, 'Prepares and serves drinks'),
    ('Waitress (Lounge)', 'general', lounge_dept_id, 'Serves customers and takes orders'),
    ('DJ (Lounge)', 'general', lounge_dept_id, 'Provides music and entertainment'),
    ('Hypeman (Lounge)', 'general', lounge_dept_id, 'Engages and entertains guests')
    ON CONFLICT (name, department_id) DO NOTHING;

    -- ============================================
    -- FUN & ARCADE DEPARTMENT ROLES (with sub-departments)
    -- ============================================
    
    DECLARE
        cinema_subdept_id UUID;
        photo_subdept_id UUID;
        saloon_subdept_id UUID;
        arcade_subdept_id UUID;
        casino_subdept_id UUID;
    BEGIN
        -- Get sub-department IDs
        SELECT id INTO cinema_subdept_id FROM sub_departments WHERE name = 'Cinema' AND department_id = fun_arcade_dept_id;
        SELECT id INTO photo_subdept_id FROM sub_departments WHERE name = 'Photo Studio' AND department_id = fun_arcade_dept_id;
        SELECT id INTO saloon_subdept_id FROM sub_departments WHERE name = 'Saloon' AND department_id = fun_arcade_dept_id;
        SELECT id INTO arcade_subdept_id FROM sub_departments WHERE name = 'Arcade and Kiddies Park' AND department_id = fun_arcade_dept_id;
        SELECT id INTO casino_subdept_id FROM sub_departments WHERE name = 'Casino' AND department_id = fun_arcade_dept_id;

        -- Cinema Sub-department
        INSERT INTO roles (name, category, department_id, sub_department_id, description) VALUES
        ('Supervisor (Cinema)', 'admin', fun_arcade_dept_id, cinema_subdept_id, 'Supervises Cinema operations'),
        ('Cinema Staff', 'general', fun_arcade_dept_id, cinema_subdept_id, 'General cinema operations staff')
        ON CONFLICT (name, department_id) DO NOTHING;

        -- Photo Studio Sub-department
        INSERT INTO roles (name, category, department_id, sub_department_id, description) VALUES
        ('Supervisor (Photo Studio)', 'admin', fun_arcade_dept_id, photo_subdept_id, 'Supervises Photo Studio operations'),
        ('Photographer', 'general', fun_arcade_dept_id, photo_subdept_id, 'Professional photographer'),
        ('Studio Staff', 'general', fun_arcade_dept_id, photo_subdept_id, 'General photo studio support staff')
        ON CONFLICT (name, department_id) DO NOTHING;

        -- Saloon Sub-department
        INSERT INTO roles (name, category, department_id, sub_department_id, description) VALUES
        ('Supervisor (Saloon)', 'admin', fun_arcade_dept_id, saloon_subdept_id, 'Supervises Saloon operations'),
        ('Hair Stylist', 'general', fun_arcade_dept_id, saloon_subdept_id, 'Professional hair stylist'),
        ('Barber', 'general', fun_arcade_dept_id, saloon_subdept_id, 'Professional barber'),
        ('Saloon Staff', 'general', fun_arcade_dept_id, saloon_subdept_id, 'General saloon support staff')
        ON CONFLICT (name, department_id) DO NOTHING;

        -- Arcade and Kiddies Park Sub-department
        INSERT INTO roles (name, category, department_id, sub_department_id, description) VALUES
        ('Manager (Arcade & Kiddies Park)', 'admin', fun_arcade_dept_id, arcade_subdept_id, 'Manages Arcade and Kiddies Park operations'),
        ('Supervisor (Arcade)', 'admin', fun_arcade_dept_id, arcade_subdept_id, 'Supervises Arcade operations'),
        ('Gamer', 'general', fun_arcade_dept_id, arcade_subdept_id, 'Arcade game operator and assistant'),
        ('Arcade Staff', 'general', fun_arcade_dept_id, arcade_subdept_id, 'General arcade support staff')
        ON CONFLICT (name, department_id) DO NOTHING;

        -- Casino Sub-department
        INSERT INTO roles (name, category, department_id, sub_department_id, description) VALUES
        ('Supervisor (Casino)', 'admin', fun_arcade_dept_id, casino_subdept_id, 'Supervises Casino operations'),
        ('Casino Staff', 'general', fun_arcade_dept_id, casino_subdept_id, 'General casino operations staff')
        ON CONFLICT (name, department_id) DO NOTHING;
    END;

    -- ============================================
    -- COMPLIANCE DEPARTMENT ROLES
    -- ============================================
    
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Compliance Officer 1', 'admin', compliance_dept_id, 'Senior compliance officer'),
    ('Assistant Compliance Officer', 'admin', compliance_dept_id, 'Assistant to compliance officer')
    ON CONFLICT (name, department_id) DO NOTHING;

    -- ============================================
    -- FACILITY MANAGEMENT DEPARTMENT ROLES
    -- ============================================
    
    INSERT INTO roles (name, category, department_id, description) VALUES
    ('Facility Manager 1', 'admin', facility_dept_id, 'Senior facility manager'),
    ('Facility Manager 2', 'admin', facility_dept_id, 'Secondary facility manager'),
    ('Security', 'general', facility_dept_id, 'Security personnel'),
    ('Cleaner', 'general', facility_dept_id, 'Cleaning and maintenance staff')
    ON CONFLICT (name, department_id) DO NOTHING;

    RAISE NOTICE '✅ All roles populated successfully!';
    RAISE NOTICE 'Total role categories:';
    RAISE NOTICE '- Senior Admin Officers: 4 roles';
    RAISE NOTICE '- Admin Officers (Group Heads): 6 roles';
    RAISE NOTICE '- Department Managers & Supervisors: ~30 roles';
    RAISE NOTICE '- General Staff: ~35 roles';
END $$;
