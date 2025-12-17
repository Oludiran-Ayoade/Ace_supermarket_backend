-- Migration: Create roster and review system
-- Roster management for floor managers with day/afternoon/night shifts

BEGIN;

-- Shift types enum
CREATE TYPE shift_type AS ENUM ('day', 'afternoon', 'night');
CREATE TYPE day_of_week AS ENUM ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');

-- Rosters table (weekly rosters created by floor managers)
CREATE TABLE IF NOT EXISTS rosters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    floor_manager_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'published', 'archived'
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_roster_week UNIQUE (floor_manager_id, week_start_date)
);

CREATE INDEX IF NOT EXISTS idx_rosters_manager ON rosters(floor_manager_id);
CREATE INDEX IF NOT EXISTS idx_rosters_week ON rosters(week_start_date, week_end_date);
CREATE INDEX IF NOT EXISTS idx_rosters_status ON rosters(status);

-- Roster assignments (individual shift assignments)
CREATE TABLE IF NOT EXISTS roster_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    roster_id UUID NOT NULL REFERENCES rosters(id) ON DELETE CASCADE,
    staff_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    day_of_week day_of_week NOT NULL,
    shift_type shift_type NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_staff_day_shift UNIQUE (roster_id, staff_id, day_of_week, shift_type)
);

CREATE INDEX IF NOT EXISTS idx_roster_assignments_roster ON roster_assignments(roster_id);
CREATE INDEX IF NOT EXISTS idx_roster_assignments_staff ON roster_assignments(staff_id);
CREATE INDEX IF NOT EXISTS idx_roster_assignments_day ON roster_assignments(day_of_week);

-- Weekly reviews (floor managers review their staff weekly)
CREATE TABLE IF NOT EXISTS weekly_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    roster_id UUID REFERENCES rosters(id) ON DELETE SET NULL,
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),
    performance_rating INTEGER CHECK (performance_rating >= 1 AND performance_rating <= 5),
    attitude_rating INTEGER CHECK (attitude_rating >= 1 AND attitude_rating <= 5),
    comments TEXT,
    strengths TEXT,
    areas_for_improvement TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_staff_week_review UNIQUE (staff_id, week_start_date, reviewer_id)
);

CREATE INDEX IF NOT EXISTS idx_weekly_reviews_staff ON weekly_reviews(staff_id);
CREATE INDEX IF NOT EXISTS idx_weekly_reviews_reviewer ON weekly_reviews(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_weekly_reviews_week ON weekly_reviews(week_start_date, week_end_date);
CREATE INDEX IF NOT EXISTS idx_weekly_reviews_rating ON weekly_reviews(rating);

-- Shift templates (predefined shift times for floor managers)
CREATE TABLE IF NOT EXISTS shift_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    floor_manager_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    shift_type shift_type NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_manager_shift_type UNIQUE (floor_manager_id, shift_type)
);

CREATE INDEX IF NOT EXISTS idx_shift_templates_manager ON shift_templates(floor_manager_id);

-- Insert default shift templates
INSERT INTO shift_templates (floor_manager_id, shift_type, start_time, end_time, is_default)
SELECT 
    u.id,
    'day',
    '08:00:00',
    '16:00:00',
    true
FROM users u
INNER JOIN roles r ON u.role_id = r.id
WHERE r.name = 'Floor Manager'
ON CONFLICT (floor_manager_id, shift_type) DO NOTHING;

INSERT INTO shift_templates (floor_manager_id, shift_type, start_time, end_time, is_default)
SELECT 
    u.id,
    'afternoon',
    '14:00:00',
    '22:00:00',
    true
FROM users u
INNER JOIN roles r ON u.role_id = r.id
WHERE r.name = 'Floor Manager'
ON CONFLICT (floor_manager_id, shift_type) DO NOTHING;

INSERT INTO shift_templates (floor_manager_id, shift_type, start_time, end_time, is_default)
SELECT 
    u.id,
    'night',
    '22:00:00',
    '06:00:00',
    true
FROM users u
INNER JOIN roles r ON u.role_id = r.id
WHERE r.name = 'Floor Manager'
ON CONFLICT (floor_manager_id, shift_type) DO NOTHING;

-- Comments
COMMENT ON TABLE rosters IS 'Weekly rosters created by floor managers';
COMMENT ON TABLE roster_assignments IS 'Individual shift assignments for staff';
COMMENT ON TABLE weekly_reviews IS 'Weekly performance reviews by floor managers';
COMMENT ON TABLE shift_templates IS 'Predefined shift times for floor managers';

COMMIT;
