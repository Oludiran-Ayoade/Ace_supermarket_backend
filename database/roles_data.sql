-- Insert all roles for Ace Mall Staff Management System

-- ============================================
-- SENIOR ADMIN OFFICERS (No department/branch specific)
-- ============================================

INSERT INTO roles (name, category, description) VALUES
('Chief Executive Officer', 'senior_admin', 'CEO - Top executive officer'),
('Chief Operating Officer', 'senior_admin', 'COO - Operations head'),
('Human Resource', 'senior_admin', 'HR - Human resources management'),
('Auditor', 'senior_admin', 'Internal auditor');

-- ============================================
-- ADMIN OFFICERS - GROUP HEADS
-- ============================================

-- SuperMarket Group Head
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Group Head (SuperMarket)', 'admin', id, 'Head of all supermarket operations across branches'
FROM departments WHERE name = 'SuperMarket';

-- Eatery Group Head
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Group Head (Eatery)', 'admin', id, 'Head of all eatery operations across branches'
FROM departments WHERE name = 'Eatery';

-- Lounge Group Head
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Group Head (Lounge)', 'admin', id, 'Head of all lounge operations across branches'
FROM departments WHERE name = 'Lounge';

-- Fun & Arcade Group Head
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Group Head (Fun & Arcade)', 'admin', id, 'Head of all entertainment operations across branches'
FROM departments WHERE name = 'Fun & Arcade';

-- Compliance Group Head
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Group Head (Compliance Officer)', 'admin', id, 'Head of compliance across all branches'
FROM departments WHERE name = 'Compliance';

-- Facility Management Group Head
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Group Head (Facility Manager)', 'admin', id, 'Head of facility management across all branches'
FROM departments WHERE name = 'Facility Management';

-- ============================================
-- SUPERMARKET DEPARTMENT ROLES
-- ============================================

-- Admin level
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Branch Manager', 'admin', id, 'SuperMarket branch manager'
FROM departments WHERE name = 'SuperMarket';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Operations Manager', 'admin', id, 'SuperMarket operations manager'
FROM departments WHERE name = 'SuperMarket';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Admin Officer', 'admin', id, 'SuperMarket admin officer'
FROM departments WHERE name = 'SuperMarket';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Floor Manager', 'admin', id, 'SuperMarket floor manager'
FROM departments WHERE name = 'SuperMarket';

-- General staff
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Cashier', 'general', id, 'SuperMarket cashier'
FROM departments WHERE name = 'SuperMarket';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Baker', 'general', id, 'SuperMarket baker'
FROM departments WHERE name = 'SuperMarket';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Customer Service Relations', 'general', id, 'SuperMarket customer service'
FROM departments WHERE name = 'SuperMarket';

-- ============================================
-- EATERY DEPARTMENT ROLES
-- ============================================

-- Admin level
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Branch Manager', 'admin', id, 'Eatery branch manager'
FROM departments WHERE name = 'Eatery';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Supervisor', 'admin', id, 'Eatery supervisor'
FROM departments WHERE name = 'Eatery';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Store Manager', 'admin', id, 'Eatery store manager'
FROM departments WHERE name = 'Eatery';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Floor Manager', 'admin', id, 'Eatery floor manager'
FROM departments WHERE name = 'Eatery';

-- General staff
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Cashier', 'general', id, 'Eatery cashier'
FROM departments WHERE name = 'Eatery';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Baker', 'general', id, 'Eatery baker'
FROM departments WHERE name = 'Eatery';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Cook', 'general', id, 'Eatery cook'
FROM departments WHERE name = 'Eatery';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Lobby Staff', 'general', id, 'Eatery lobby staff'
FROM departments WHERE name = 'Eatery';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Kitchen Assistant', 'general', id, 'Eatery kitchen assistant'
FROM departments WHERE name = 'Eatery';

-- ============================================
-- LOUNGE DEPARTMENT ROLES
-- ============================================

-- Admin level
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Branch Manager', 'admin', id, 'Lounge branch manager'
FROM departments WHERE name = 'Lounge';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Operations Manager', 'admin', id, 'Lounge operations manager'
FROM departments WHERE name = 'Lounge';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Supervisor', 'admin', id, 'Lounge supervisor'
FROM departments WHERE name = 'Lounge';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Floor Manager', 'admin', id, 'Lounge floor manager'
FROM departments WHERE name = 'Lounge';

-- General staff
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Cashier', 'general', id, 'Lounge cashier'
FROM departments WHERE name = 'Lounge';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Cook', 'general', id, 'Lounge cook'
FROM departments WHERE name = 'Lounge';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Bartender', 'general', id, 'Lounge bartender'
FROM departments WHERE name = 'Lounge';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Waitress', 'general', id, 'Lounge waitress'
FROM departments WHERE name = 'Lounge';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'DJ', 'general', id, 'Lounge DJ'
FROM departments WHERE name = 'Lounge';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Hypeman', 'general', id, 'Lounge hypeman'
FROM departments WHERE name = 'Lounge';

-- ============================================
-- FUN & ARCADE DEPARTMENT ROLES
-- ============================================

-- Department Manager (Main F&A Manager)
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Fun & Arcade Department Manager', 'admin', id, 'Main manager for Fun & Arcade department'
FROM departments WHERE name = 'Fun & Arcade';

-- Cinema Sub-department
INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Cinema Supervisor', 'admin', d.id, sd.id, 'Cinema operations supervisor'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Cinema';

INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Cinema Staff', 'general', d.id, sd.id, 'Cinema general staff'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Cinema';

-- Photo Studio Sub-department
INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Photo Studio Supervisor', 'admin', d.id, sd.id, 'Photo studio supervisor'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Photo Studio';

INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Photographer', 'general', d.id, sd.id, 'Professional photographer'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Photo Studio';

INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Studio Staff', 'general', d.id, sd.id, 'Photo studio staff'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Photo Studio';

-- Saloon Sub-department
INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Saloon Supervisor', 'admin', d.id, sd.id, 'Saloon operations supervisor'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Saloon';

INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Hair Stylist', 'general', d.id, sd.id, 'Professional hair stylist'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Saloon';

INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Barber', 'general', d.id, sd.id, 'Professional barber'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Saloon';

INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Saloon Staff', 'general', d.id, sd.id, 'Saloon general staff'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Saloon';

-- Arcade and Kiddies Park Sub-department
INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Arcade Supervisor', 'admin', d.id, sd.id, 'Arcade and kiddies park supervisor'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Arcade and Kiddies Park';

INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Gamer', 'general', d.id, sd.id, 'Arcade gamer/attendant'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Arcade and Kiddies Park';

INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Arcade Staff', 'general', d.id, sd.id, 'Arcade general staff'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Arcade and Kiddies Park';

-- Casino Sub-department
INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Casino Supervisor', 'admin', d.id, sd.id, 'Casino operations supervisor'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Casino';

INSERT INTO roles (name, category, department_id, sub_department_id, description) 
SELECT 'Casino Staff', 'general', d.id, sd.id, 'Casino general staff'
FROM departments d, sub_departments sd 
WHERE d.name = 'Fun & Arcade' AND sd.name = 'Casino';

-- ============================================
-- COMPLIANCE DEPARTMENT ROLES
-- ============================================

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Compliance Officer 1', 'admin', id, 'Senior compliance officer'
FROM departments WHERE name = 'Compliance';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Assistant Compliance Officer', 'admin', id, 'Assistant compliance officer'
FROM departments WHERE name = 'Compliance';

-- ============================================
-- FACILITY MANAGEMENT DEPARTMENT ROLES
-- ============================================

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Facility Manager 1', 'admin', id, 'Senior facility manager'
FROM departments WHERE name = 'Facility Management';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Facility Manager 2', 'admin', id, 'Facility manager'
FROM departments WHERE name = 'Facility Management';

-- General staff under Facility Management
INSERT INTO roles (name, category, department_id, description) 
SELECT 'Security', 'general', id, 'Security personnel'
FROM departments WHERE name = 'Facility Management';

INSERT INTO roles (name, category, department_id, description) 
SELECT 'Cleaner', 'general', id, 'Cleaning staff'
FROM departments WHERE name = 'Facility Management';
