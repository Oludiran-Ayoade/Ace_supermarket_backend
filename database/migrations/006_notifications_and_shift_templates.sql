-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('shift_reminder', 'roster_assignment', 'schedule_change', 'review', 'general')),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;

-- Shift templates table (customizable shift times for floor managers)
CREATE TABLE IF NOT EXISTS shift_templates (
    id SERIAL PRIMARY KEY,
    floor_manager_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    shift_type VARCHAR(20) NOT NULL CHECK (shift_type IN ('day', 'afternoon', 'night')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(floor_manager_id, shift_type)
);

CREATE INDEX idx_shift_templates_floor_manager ON shift_templates(floor_manager_id);

-- Insert default shift templates for existing floor managers
INSERT INTO shift_templates (floor_manager_id, shift_type, start_time, end_time)
SELECT 
    u.id,
    shift_type,
    CASE 
        WHEN shift_type = 'day' THEN '07:00:00'
        WHEN shift_type = 'afternoon' THEN '15:00:00'
        WHEN shift_type = 'night' THEN '23:00:00'
    END as start_time,
    CASE 
        WHEN shift_type = 'day' THEN '15:00:00'
        WHEN shift_type = 'afternoon' THEN '23:00:00'
        WHEN shift_type = 'night' THEN '07:00:00'
    END as end_time
FROM users u
CROSS JOIN (VALUES ('day'), ('afternoon'), ('night')) AS shifts(shift_type)
WHERE u.role_id IN (SELECT id FROM roles WHERE name LIKE '%Floor Manager%')
ON CONFLICT (floor_manager_id, shift_type) DO NOTHING;

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shift_templates_updated_at BEFORE UPDATE ON shift_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Add indexes for better performance on reviews table
CREATE INDEX IF NOT EXISTS idx_reviews_staff_id_date ON reviews(staff_id, review_date DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewer_id ON reviews(reviewer_id);

-- Add indexes for roster_assignments
CREATE INDEX IF NOT EXISTS idx_roster_assignments_staff_id ON roster_assignments(staff_id);
CREATE INDEX IF NOT EXISTS idx_roster_assignments_roster_day ON roster_assignments(roster_id, day_of_week);
