-- ============================================
-- CREATE SUB-DEPARTMENT MANAGERS
-- ============================================
-- Password for all: password123
-- Bcrypt hash: $2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO
-- ============================================

-- Cinema Manager - Abeokuta
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'cinema.abeokuta@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Mr. Tayo Adeyemi',
    (SELECT id FROM roles WHERE name = 'Manager (Cinema)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Cinema'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Abeokuta'),
    '08012345601',
    'Male',
    CURRENT_DATE - INTERVAL '6 months',
    true
);

-- Cinema Manager - Bodija
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'cinema.bodija@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Miss Funke Oladele',
    (SELECT id FROM roles WHERE name = 'Manager (Cinema)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Cinema'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Bodija'),
    '08012345602',
    'Female',
    CURRENT_DATE - INTERVAL '8 months',
    true
);

-- Cinema Manager - Akobo
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'cinema.akobo@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Mr. Segun Afolabi',
    (SELECT id FROM roles WHERE name = 'Manager (Cinema)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Cinema'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Akobo'),
    '08012345603',
    'Male',
    CURRENT_DATE - INTERVAL '5 months',
    true
);

-- Photo Studio Manager - Abeokuta
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'photostudio.abeokuta@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Mrs. Kemi Adebayo',
    (SELECT id FROM roles WHERE name = 'Manager (Photo Studio)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Photo Studio'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Abeokuta'),
    '08012345604',
    'Female',
    CURRENT_DATE - INTERVAL '7 months',
    true
);

-- Photo Studio Manager - Bodija
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'photostudio.bodija@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Mr. Wale Ogunbiyi',
    (SELECT id FROM roles WHERE name = 'Manager (Photo Studio)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Photo Studio'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Bodija'),
    '08012345605',
    'Male',
    CURRENT_DATE - INTERVAL '9 months',
    true
);

-- Photo Studio Manager - Akobo
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'photostudio.akobo@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Miss Shade Akinola',
    (SELECT id FROM roles WHERE name = 'Manager (Photo Studio)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Photo Studio'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Akobo'),
    '08012345606',
    'Female',
    CURRENT_DATE - INTERVAL '4 months',
    true
);

-- Saloon Manager - Abeokuta
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'saloon.abeokuta@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Miss Blessing Okoro',
    (SELECT id FROM roles WHERE name = 'Manager (Saloon)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Saloon'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Abeokuta'),
    '08012345607',
    'Female',
    CURRENT_DATE - INTERVAL '10 months',
    true
);

-- Saloon Manager - Bodija
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'saloon.bodija@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Mr. Gbenga Fashola',
    (SELECT id FROM roles WHERE name = 'Manager (Saloon)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Saloon'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Bodija'),
    '08012345608',
    'Male',
    CURRENT_DATE - INTERVAL '6 months',
    true
);

-- Saloon Manager - Akobo
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'saloon.akobo@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Mrs. Yetunde Olatunji',
    (SELECT id FROM roles WHERE name = 'Manager (Saloon)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Saloon'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Akobo'),
    '08012345609',
    'Female',
    CURRENT_DATE - INTERVAL '7 months',
    true
);

-- Arcade Manager - Abeokuta
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'arcade.abeokuta@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Mr. Kunle Adeleke',
    (SELECT id FROM roles WHERE name = 'Manager (Arcade & Kiddies Park)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Arcade & Kiddies Park'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Abeokuta'),
    '08012345610',
    'Male',
    CURRENT_DATE - INTERVAL '5 months',
    true
);

-- Arcade Manager - Bodija
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'arcade.bodija@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Miss Zainab Ibrahim',
    (SELECT id FROM roles WHERE name = 'Manager (Arcade & Kiddies Park)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Arcade & Kiddies Park'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Bodija'),
    '08012345611',
    'Female',
    CURRENT_DATE - INTERVAL '8 months',
    true
);

-- Arcade Manager - Akobo
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'arcade.akobo@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Mr. Biodun Alabi',
    (SELECT id FROM roles WHERE name = 'Manager (Arcade & Kiddies Park)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Arcade & Kiddies Park'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Akobo'),
    '08012345612',
    'Male',
    CURRENT_DATE - INTERVAL '6 months',
    true
);

-- Casino Manager - Abeokuta
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'casino.abeokuta@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Mr. Chidi Okonkwo',
    (SELECT id FROM roles WHERE name = 'Manager (Casino)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Casino'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Abeokuta'),
    '08012345613',
    'Male',
    CURRENT_DATE - INTERVAL '9 months',
    true
);

-- Casino Manager - Bodija
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'casino.bodija@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Mrs. Amaka Nwosu',
    (SELECT id FROM roles WHERE name = 'Manager (Casino)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Casino'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Bodija'),
    '08012345614',
    'Female',
    CURRENT_DATE - INTERVAL '7 months',
    true
);

-- Casino Manager - Akobo
INSERT INTO users (email, password_hash, full_name, role_id, department_id, sub_department_id, branch_id, phone_number, gender, date_joined, is_active)
VALUES (
    'casino.akobo@acesupermarket.com',
    '$2a$10$YhFHq1HZ5HvLZVbLw5wY4.3Z8KqVnJ5xGqJ5XqJ5xGqJ5XqJ5xGqJO',
    'Mr. Lanre Adebisi',
    (SELECT id FROM roles WHERE name = 'Manager (Casino)'),
    (SELECT id FROM departments WHERE name = 'Fun & Arcade'),
    (SELECT id FROM sub_departments WHERE name = 'Casino'),
    (SELECT id FROM branches WHERE name = 'Ace Mall, Akobo'),
    '08012345615',
    'Male',
    CURRENT_DATE - INTERVAL '5 months',
    true
);

-- Success message
SELECT '✅ Successfully created 15 Sub-Department Managers!' AS status;
SELECT '   - 3 Cinema Managers' AS details;
SELECT '   - 3 Photo Studio Managers' AS details;
SELECT '   - 3 Saloon Managers' AS details;
SELECT '   - 3 Arcade Managers' AS details;
SELECT '   - 3 Casino Managers' AS details;
SELECT '' AS blank;
SELECT '🔑 All accounts use password: password123' AS credentials;
