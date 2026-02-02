-- Update user roles with correct role IDs
-- Password for all: password123

DO $$
DECLARE
    ceo_role UUID;
    chairman_role UUID;
    hr_role UUID;
    branch_mgr_supermarket UUID;
    floor_mgr_supermarket UUID;
    floor_mgr_lounge UUID;
    floor_mgr_cinema UUID;
    cashier_supermarket UUID;
    cook_lounge UUID;
    cook_eatery UUID;
    security_role UUID;
    cinema_supervisor UUID;
BEGIN
    -- Get role IDs
    SELECT id INTO ceo_role FROM roles WHERE name = 'Chief Executive Officer' LIMIT 1;
    SELECT id INTO chairman_role FROM roles WHERE name = 'Chairman' LIMIT 1;
    SELECT id INTO hr_role FROM roles WHERE name = 'Human Resource' LIMIT 1;
    SELECT id INTO branch_mgr_supermarket FROM roles WHERE name = 'Branch Manager (SuperMarket)' LIMIT 1;
    SELECT id INTO floor_mgr_supermarket FROM roles WHERE name = 'Floor Manager (SuperMarket)' LIMIT 1;
    SELECT id INTO floor_mgr_lounge FROM roles WHERE name = 'Floor Manager (Lounge)' LIMIT 1;
    SELECT id INTO cashier_supermarket FROM roles WHERE name = 'Cashier (SuperMarket)' LIMIT 1;
    SELECT id INTO cook_lounge FROM roles WHERE name = 'Cook (Lounge)' LIMIT 1;
    SELECT id INTO cook_eatery FROM roles WHERE name = 'Cook (Eatery)' LIMIT 1;
    SELECT id INTO security_role FROM roles WHERE name = 'Security' LIMIT 1;
    SELECT id INTO cinema_supervisor FROM roles WHERE name = 'Cinema Supervisor' LIMIT 1;
    
    -- Update CEO
    UPDATE users SET role_id = ceo_role WHERE email = 'ceo@acemarket.com';
    
    -- Update Chairman  
    UPDATE users SET role_id = chairman_role WHERE email = 'chairman@acemarket.com';
    
    -- Update HR
    UPDATE users SET role_id = hr_role WHERE email = 'hr@acemarket.com';
    
    -- Update Branch Managers
    UPDATE users SET role_id = branch_mgr_supermarket WHERE email IN (
        'bm.ogbomosho@acemarket.com',
        'bm.bodija@acemarket.com',
        'bm.akobo@acemarket.com',
        'bm.oluyole@acemarket.com',
        'bm.oyo@acemarket.com'
    );
    
    -- Update Floor Manager - Supermarket
    UPDATE users SET role_id = floor_mgr_supermarket WHERE email = 'fm.supermarket.ogbomosho@acemarket.com';
    
    -- Update Floor Manager - Lounge
    UPDATE users SET role_id = floor_mgr_lounge WHERE email = 'fm.lounge.bodija@acemarket.com';
    
    -- Update Floor Manager - Cinema (using Cinema Supervisor role)
    UPDATE users SET role_id = cinema_supervisor WHERE email IN (
        'fm.cinema.oyo@acemarket.com',
        'fm.arcade.akobo@acemarket.com',
        'fm.bakery.oluyole@acemarket.com'
    );
    
    -- Update Cashier
    UPDATE users SET role_id = cashier_supermarket WHERE email = 'cashier.ogbomosho@acemarket.com';
    
    -- Update Cooks
    UPDATE users SET role_id = cook_lounge WHERE email IN (
        'cook.bodija@acemarket.com',
        'bartender.bodija@acemarket.com'
    );
    
    UPDATE users SET role_id = cook_eatery WHERE email IN (
        'baker.oluyole@acemarket.com'
    );
    
    -- Update Security
    UPDATE users SET role_id = security_role WHERE email = 'security.akobo@acemarket.com';
    
    -- Update remaining general staff with appropriate roles
    UPDATE users SET role_id = cashier_supermarket WHERE email IN (
        'usher.oyo@acemarket.com',
        'attendant.akobo@acemarket.com'
    );
    
    RAISE NOTICE 'User roles updated successfully!';
END $$;
