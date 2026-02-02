-- Complete Database Setup for Ace Mall Staff Management System
-- Run this script to set up the entire database from scratch

-- ============================================
-- STEP 1: Enable UUID extension
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- STEP 2: Create all tables
-- ============================================

-- Branches Table
CREATE TABLE IF NOT EXISTS branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(200) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Departments Table
CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sub-departments (for Fun & Arcade)
CREATE TABLE IF NOT EXISTS sub_departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    department_id UUID REFERENCES departments(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Roles/Positions Table
CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    department_id UUID REFERENCES departments(id),
    sub_department_id UUID REFERENCES sub_departments(id),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, department_id)
);

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    
    -- Personal Information
    full_name VARCHAR(200) NOT NULL,
    gender VARCHAR(20),
    date_of_birth DATE,
    marital_status VARCHAR(50),
    phone_number VARCHAR(20),
    home_address TEXT,
    state_of_origin VARCHAR(100),
    
    -- Work Information
    employee_id VARCHAR(50) UNIQUE,
    role_id UUID REFERENCES roles(id),
    department_id UUID REFERENCES departments(id),
    sub_department_id UUID REFERENCES sub_departments(id),
    branch_id UUID REFERENCES branches(id),
    date_joined DATE NOT NULL,
    current_salary DECIMAL(12, 2),
    
    -- Education
    course_of_study VARCHAR(200),
    grade VARCHAR(50),
    institution VARCHAR(200),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_terminated BOOLEAN DEFAULT false,
    termination_reason TEXT,
    termination_date DATE,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- ============================================
-- STEP 3: Insert default data
-- ============================================

-- Insert 14 Branches
INSERT INTO branches (name, location) VALUES
('Ace Mall, Oluyole', 'Oluyole, Ibadan'),
('Ace Mall, Bodija', 'Bodija, Ibadan'),
('Ace Mall, Akobo', 'Akobo, Ibadan'),
('Ace Mall, Oyo', 'Oyo Town'),
('Ace Mall, Ogbomosho', 'Ogbomosho'),
('Ace Mall, Ilorin', 'Ilorin, Kwara'),
('Ace Mall, Iseyin', 'Iseyin'),
('Ace Mall, Saki', 'Saki'),
('Ace Mall, Ife', 'Ile-Ife'),
('Ace Mall, Osogbo', 'Osogbo'),
('Ace Mall, Abeokuta', 'Abeokuta'),
('Ace Mall, Ijebu', 'Ijebu-Ode'),
('Ace Mall, Sagamu', 'Sagamu'),
('Ace Mall, Challenge', 'Challenge, Ibadan')
ON CONFLICT (name) DO NOTHING;

-- Insert 6 Main Departments
INSERT INTO departments (name, description) VALUES
('SuperMarket', 'Retail supermarket operations'),
('Eatery', 'Restaurant and food services'),
('Lounge', 'Bar and lounge services'),
('Fun & Arcade', 'Entertainment and recreation'),
('Compliance', 'Compliance and regulatory affairs'),
('Facility Management', 'Facility maintenance and security')
ON CONFLICT (name) DO NOTHING;

-- Insert Sub-departments for Fun & Arcade
INSERT INTO sub_departments (department_id, name) 
SELECT d.id, 'Cinema' FROM departments d WHERE d.name = 'Fun & Arcade'
ON CONFLICT DO NOTHING;

INSERT INTO sub_departments (department_id, name) 
SELECT d.id, 'Photo Studio' FROM departments d WHERE d.name = 'Fun & Arcade'
ON CONFLICT DO NOTHING;

INSERT INTO sub_departments (department_id, name) 
SELECT d.id, 'Saloon' FROM departments d WHERE d.name = 'Fun & Arcade'
ON CONFLICT DO NOTHING;

INSERT INTO sub_departments (department_id, name) 
SELECT d.id, 'Arcade and Kiddies Park' FROM departments d WHERE d.name = 'Fun & Arcade'
ON CONFLICT DO NOTHING;

INSERT INTO sub_departments (department_id, name) 
SELECT d.id, 'Casino' FROM departments d WHERE d.name = 'Fun & Arcade'
ON CONFLICT DO NOTHING;

-- ============================================
-- STEP 4: Create HR role and user
-- ============================================

DO $$ 
DECLARE
    hr_role_id UUID;
BEGIN
    -- Create HR role
    INSERT INTO roles (name, category, description)
    VALUES ('HR Administrator', 'senior_admin', 'Human Resources Administrator with full system access')
    ON CONFLICT (name, department_id) DO NOTHING
    RETURNING id INTO hr_role_id;
    
    -- If role already exists, get its ID
    IF hr_role_id IS NULL THEN
        SELECT id INTO hr_role_id FROM roles WHERE name = 'HR Administrator' AND department_id IS NULL;
    END IF;
    
    -- Create HR user
    -- Password: password123
    -- Hash generated using bcrypt.GenerateFromPassword
    INSERT INTO users (
        email,
        password_hash,
        full_name,
        role_id,
        date_joined,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        'hr@acemarket.com',
        '$2a$10$e8JIKJMKMlaleLpvLxAf7ew7XWw2QX6FFDbiDPEtfttD3wQHrvZ..',
        'HR Administrator',
        hr_role_id,
        CURRENT_DATE,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (email) DO NOTHING;
    
    RAISE NOTICE '✅ Database setup complete!';
    RAISE NOTICE '✅ HR user created successfully!';
    RAISE NOTICE 'Email: hr@acemarket.com';
    RAISE NOTICE 'Password: password123';
END $$;
