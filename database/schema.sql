-- Ace Mall Staff Management System Database Schema
-- PostgreSQL Database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- CORE TABLES
-- ============================================

-- Branches Table
CREATE TABLE branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(200) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Departments Table (HR can add new departments)
CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sub-departments (for Fun & Arcade)
CREATE TABLE sub_departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    department_id UUID REFERENCES departments(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Roles/Positions Table
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL, -- 'senior_admin', 'admin', 'general'
    department_id UUID REFERENCES departments(id),
    sub_department_id UUID REFERENCES sub_departments(id),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, department_id)
);

-- ============================================
-- USER MANAGEMENT
-- ============================================

-- Users Table (All Staff)
CREATE TABLE users (
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
    grade VARCHAR(50), -- e.g., "2-1", "1st Class"
    institution VARCHAR(200),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_terminated BOOLEAN DEFAULT false,
    termination_reason TEXT,
    termination_date DATE,
    
    -- Metadata
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- User Hierarchy (Manager-Subordinate relationships)
CREATE TABLE user_hierarchy (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    manager_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- DOCUMENTS & CERTIFICATIONS
-- ============================================

-- User Documents
CREATE TABLE user_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    document_type VARCHAR(100) NOT NULL, -- 'birth_certificate', 'passport', 'valid_id', etc.
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INTEGER,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exam Scores
CREATE TABLE exam_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    exam_type VARCHAR(100) NOT NULL, -- 'WAEC', 'NECO', 'JAMB', etc.
    score VARCHAR(50),
    year_taken INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- NEXT OF KIN & GUARANTORS
-- ============================================

-- Next of Kin
CREATE TABLE next_of_kin (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(200) NOT NULL,
    relationship VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone_number VARCHAR(20) NOT NULL,
    home_address TEXT,
    work_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Guarantors
CREATE TABLE guarantors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    guarantor_number INTEGER NOT NULL, -- 1 or 2
    full_name VARCHAR(200) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    occupation VARCHAR(200),
    relationship VARCHAR(100),
    sex VARCHAR(20),
    age INTEGER,
    home_address TEXT,
    email VARCHAR(255),
    date_of_birth DATE,
    grade_level VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, guarantor_number)
);

-- Guarantor Documents
CREATE TABLE guarantor_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guarantor_id UUID REFERENCES guarantors(id) ON DELETE CASCADE,
    document_type VARCHAR(100) NOT NULL, -- 'passport', 'national_id', 'work_id'
    file_path VARCHAR(500) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- WORK HISTORY & PROMOTIONS
-- ============================================

-- Work Experience (Previous employment)
CREATE TABLE work_experience (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    company_name VARCHAR(200) NOT NULL,
    position VARCHAR(200) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    responsibilities TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Role History (Roles held within Ace Mall)
CREATE TABLE role_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID REFERENCES roles(id),
    department_id UUID REFERENCES departments(id),
    branch_id UUID REFERENCES branches(id),
    start_date DATE NOT NULL,
    end_date DATE,
    promotion_reason TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- ROSTER & REVIEWS
-- ============================================

-- Rosters
CREATE TABLE rosters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    branch_id UUID REFERENCES branches(id),
    department_id UUID REFERENCES departments(id),
    floor_manager_id UUID REFERENCES users(id),
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'published', 'completed'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Roster Assignments
CREATE TABLE roster_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    roster_id UUID REFERENCES rosters(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    shift_day VARCHAR(20) NOT NULL, -- 'Monday', 'Tuesday', etc.
    shift_start_time TIME NOT NULL,
    shift_end_time TIME NOT NULL,
    status VARCHAR(50) DEFAULT 'scheduled', -- 'scheduled', 'present', 'absent', 'late'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Weekly Reviews
CREATE TABLE weekly_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    roster_id UUID REFERENCES rosters(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    reviewer_id UUID REFERENCES users(id), -- Floor Manager
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comments TEXT,
    review_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TERMINATED STAFF
-- ============================================

-- Terminated Staff Records
CREATE TABLE terminated_staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    full_name VARCHAR(200) NOT NULL,
    role_name VARCHAR(100),
    department_name VARCHAR(100),
    branch_name VARCHAR(100),
    date_joined DATE,
    termination_date DATE NOT NULL,
    termination_reason TEXT NOT NULL,
    terminated_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_employee_id ON users(employee_id);
CREATE INDEX idx_users_branch ON users(branch_id);
CREATE INDEX idx_users_department ON users(department_id);
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_users_active ON users(is_active);
CREATE INDEX idx_roster_assignments_user ON roster_assignments(user_id);
CREATE INDEX idx_roster_assignments_roster ON roster_assignments(roster_id);
CREATE INDEX idx_weekly_reviews_user ON weekly_reviews(user_id);
CREATE INDEX idx_role_history_user ON role_history(user_id);

-- ============================================
-- INSERT DEFAULT DATA
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
('Ace Mall, Challenge', 'Challenge, Ibadan');

-- Insert 6 Main Departments
INSERT INTO departments (name, description) VALUES
('SuperMarket', 'Retail supermarket operations'),
('Eatery', 'Restaurant and food services'),
('Lounge', 'Bar and lounge services'),
('Fun & Arcade', 'Entertainment and recreation'),
('Compliance', 'Compliance and regulatory affairs'),
('Facility Management', 'Facility maintenance and security');

-- Insert Sub-departments for Fun & Arcade
INSERT INTO sub_departments (department_id, name) 
SELECT id, 'Cinema' FROM departments WHERE name = 'Fun & Arcade'
UNION ALL
SELECT id, 'Photo Studio' FROM departments WHERE name = 'Fun & Arcade'
UNION ALL
SELECT id, 'Saloon' FROM departments WHERE name = 'Fun & Arcade'
UNION ALL
SELECT id, 'Arcade and Kiddies Park' FROM departments WHERE name = 'Fun & Arcade'
UNION ALL
SELECT id, 'Casino' FROM departments WHERE name = 'Fun & Arcade';
