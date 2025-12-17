-- Seed Users for All Hierarchies in Ace Supermarket
-- Password for ALL accounts: password123
-- Bcrypt hash: $2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP

-- Insert users (name, email, password)
-- The password hash is for "password123"

-- SENIOR ADMIN (already exists, but adding more)
INSERT INTO users (name, email, password) VALUES
    ('Chief Oluwaseun Ogunleye (Chairman)', 'chairman@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP')
ON CONFLICT (email) DO NOTHING;

-- BRANCH MANAGERS
INSERT INTO users (name, email, password) VALUES
    ('Mr. Tunde Bakare (Branch Manager - Ogbomosho)', 'bm.ogbomosho@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Mrs. Blessing Okonkwo (Branch Manager - Bodija)', 'bm.bodija@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Mr. Ibrahim Yusuf (Branch Manager - Akobo)', 'bm.akobo@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Mrs. Kemi Adeleke (Branch Manager - Oluyole)', 'bm.oluyole@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Mr. Segun Ajayi (Branch Manager - Oyo)', 'bm.oyo@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP')
ON CONFLICT (email) DO NOTHING;

-- FLOOR MANAGERS
INSERT INTO users (name, email, password) VALUES
    ('Mr. Adebayo Fashola (Floor Manager - Supermarket, Ogbomosho)', 'fm.supermarket.ogbomosho@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Mrs. Sarah Ogundimu (Floor Manager - Lounge, Bodija)', 'fm.lounge.bodija@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Mr. Chukwudi Eze (Floor Manager - Arcade, Akobo)', 'fm.arcade.akobo@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Mrs. Ngozi Okeke (Floor Manager - Bakery, Oluyole)', 'fm.bakery.oluyole@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Mr. Yusuf Mohammed (Floor Manager - Cinema, Oyo)', 'fm.cinema.oyo@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP')
ON CONFLICT (email) DO NOTHING;

-- GENERAL STAFF
INSERT INTO users (name, email, password) VALUES
    ('Biodun Alabi (Cashier - Supermarket, Ogbomosho)', 'cashier.ogbomosho@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Chioma Nwankwo (Cook - Lounge, Bodija)', 'cook.bodija@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Emeka Okafor (Bartender - Lounge, Bodija)', 'bartender.bodija@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Musa Abdullahi (Security Guard - Akobo)', 'security.akobo@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Fatima Bello (Baker - Bakery, Oluyole)', 'baker.oluyole@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Tunde Adeyemi (Usher - Cinema, Oyo)', 'usher.oyo@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP'),
    ('Amaka Obi (Arcade Attendant - Arcade, Akobo)', 'attendant.akobo@acemarket.com', '$2a$10$rKvVLz4VZ5FqP8yN.xQxXuqGJ8mYHjYxvfVXKKZ8qYxVLz4VZ5FqP')
ON CONFLICT (email) DO NOTHING;

-- Display results
SELECT 'Users created successfully!' as message;
SELECT '========================================' as separator;
SELECT 'Password for ALL accounts: password123' as info;
SELECT '========================================' as separator;
