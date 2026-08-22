CREATE DATABASE IF NOT EXISTS globetrotter_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE globetrotter_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS stop_activities;
DROP TABLE IF EXISTS trip_stops;
DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS destinations;

CREATE TABLE trips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    transport_cost DECIMAL(10,2) DEFAULT 0.00,
    hotel_cost DECIMAL(10,2) DEFAULT 0.00,
    meal_cost DECIMAL(10,2) DEFAULT 0.00,
    share_token VARCHAR(64) UNIQUE,
    status VARCHAR(50) DEFAULT 'Planned',
    description TEXT,
    cover_image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE trip_stops (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT NOT NULL,
    city_name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    stop_order INT NOT NULL DEFAULT 1,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    notes TEXT,
    FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
);

CREATE TABLE stop_activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    stop_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    category VARCHAR(50) DEFAULT 'Sightseeing',
    time_slot VARCHAR(50) DEFAULT '09:00 AM',
    cost DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    activity_order INT DEFAULT 1,
    FOREIGN KEY (stop_id) REFERENCES trip_stops(id) ON DELETE CASCADE
);

CREATE TABLE destinations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    region VARCHAR(50) DEFAULT 'Europe',
    image_url VARCHAR(255),
    average_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    cost_index VARCHAR(10) DEFAULT '$$$',
    popularity_score DECIMAL(3,1) DEFAULT 4.8,
    view_count INT DEFAULT 0,
    visit_count INT DEFAULT 0,
    description TEXT
);

CREATE TABLE activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    destination_id INT,
    title VARCHAR(150) NOT NULL,
    category VARCHAR(50) DEFAULT 'Sightseeing',
    duration VARCHAR(50) DEFAULT '2 hours',
    cost DECIMAL(10,2) DEFAULT 0.00,
    description TEXT,
    image_url VARCHAR(255),
    popularity_score DECIMAL(3,1) DEFAULT 4.8,
    FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE SET NULL
);

-- Seed initial test user
INSERT INTO users (id, name, email, password_hash) 
VALUES (1, 'Alex Morgan', 'alex@globetrotter.com', '$2y$10$e8p2UeIqNkW43H2sWk7e9.bN4V4x5Z4W4y5Z4W4y5Z4W4y5Z4W4y5')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 1. SEED TRIPS WITH CATEGORIZED EXPENSES & SHARE TOKENS
INSERT INTO trips (id, user_id, title, destination, start_date, end_date, budget, transport_cost, hotel_cost, meal_cost, share_token, status, description, cover_image_url)
VALUES 
(1, 1, 'Euro Summer Getaway', 'Paris & Rome', '2026-09-10', '2026-09-20', 2500.00, 650.00, 1100.00, 550.00, 'share_euro_summer_2026', 'Confirmed', 'An exciting 10-day tour across romantic Paris landmarks and historic Roman ruins.', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80'),
(2, 1, 'Japan Autumn Exploration', 'Tokyo, Kyoto & Osaka', '2026-11-01', '2026-11-12', 3500.00, 850.00, 1400.00, 700.00, 'share_japan_autumn_2026', 'Planned', 'Discovering vibrant Tokyo technology, traditional Kyoto shrines, and Osaka food stalls during autumn foliage.', 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=600&q=80'),
(3, 1, 'Swiss Alps Winter Wonderland', 'Zurich, Lucerne & Zermatt', '2026-12-15', '2026-12-24', 4500.00, 950.00, 2100.00, 900.00, 'share_swiss_alps_2026', 'Planned', 'Enjoying alpine snowscapes, glacier cable cars, lake cruises, and authentic Swiss fondue.', 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=600&q=80'),
(4, 1, 'Bali Tropical Beach & Temple Escape', 'Ubud & Seminyak', '2027-02-10', '2027-02-18', 1800.00, 500.00, 750.00, 350.00, 'share_bali_escape_2027', 'Planned', 'Relaxing in private pool villas, visiting cliffside temples, and swinging over lush terraced rice fields.', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=80'),
(5, 1, 'Iceland Northern Lights & Glaciers', 'Reykjavik & Vik', '2027-03-05', '2027-03-12', 3600.00, 750.00, 1600.00, 650.00, 'share_iceland_lights_2027', 'Planned', 'Chasing the Aurora Borealis, soaking in the Blue Lagoon, and exploring ice caves on black sand beaches.', 'https://images.unsplash.com/photo-1504893524553-b855bce32c67?auto=format&fit=crop&w=600&q=80'),
(6, 1, 'Costa Rica Rainforest & Volcano Safari', 'La Fortuna & Manuel Antonio', '2027-05-12', '2027-05-20', 2200.00, 450.00, 950.00, 400.00, 'share_costa_rica_2027', 'Planned', 'Hiking active volcanoes, walking sloth canopy hanging bridges, and snorkeling in Pacific nature reserves.', 'https://images.unsplash.com/photo-1518638150340-f706e86654de?auto=format&fit=crop&w=600&q=80'),
(7, 1, 'Spanish Tapas & Andalusian Heritage', 'Barcelona & Seville', '2027-06-10', '2027-06-18', 2800.00, 600.00, 1200.00, 500.00, 'share_spain_tapas_2027', 'Planned', 'Experiencing Sagrada Familia Gaudi architecture, authentic flamenco dancing, and tapas food tours.', 'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?auto=format&fit=crop&w=600&q=80'),
(8, 1, 'African Wildlife Safari & Cape Town', 'Cape Town & Kruger Park', '2027-08-01', '2027-08-10', 4800.00, 1100.00, 2200.00, 800.00, 'share_africa_safari_2027', 'Planned', 'Riding Table Mountain cableway, observing Boulders Beach penguins, and tracking the Big Five on safari.', 'https://images.unsplash.com/photo-1516426122078-c23e76319801?auto=format&fit=crop&w=600&q=80');

-- 2. SEED CITY STOPS
INSERT INTO trip_stops (id, trip_id, city_name, country, stop_order, start_date, end_date, notes)
VALUES
(1, 1, 'Paris', 'France', 1, '2026-09-10', '2026-09-15', 'Hotel in Le Marais district, museum passes reserved'),
(2, 1, 'Rome', 'Italy', 2, '2026-09-16', '2026-09-20', 'Boutique hotel near Piazza Navona, Colosseum fast-track tickets'),
(3, 2, 'Tokyo', 'Japan', 1, '2026-11-01', '2026-11-05', 'Shinjuku skyscraper hotel, Suica transit cards ready'),
(4, 2, 'Kyoto', 'Japan', 2, '2026-11-06', '2026-11-09', 'Traditional Ryokan in Gion, private tea ceremony reservation'),
(5, 2, 'Osaka', 'Japan', 3, '2026-11-10', '2026-11-12', 'Hotel near Dotonbori food district'),
(6, 3, 'Zurich', 'Switzerland', 1, '2026-12-15', '2026-12-17', 'Lakefront hotel, Old Town walking route planned'),
(7, 3, 'Lucerne', 'Switzerland', 2, '2026-12-18', '2026-12-21', 'Chapel Bridge hotel, Mt. Titlis cable car tickets'),
(8, 3, 'Zermatt', 'Switzerland', 3, '2026-12-22', '2026-12-24', 'Car-free chalet village, Matterhorn Gornergrat railway'),
(9, 4, 'Ubud', 'Indonesia', 1, '2027-02-10', '2027-02-14', 'Jungle valley resort villa, organic spa booking'),
(10, 4, 'Seminyak', 'Indonesia', 2, '2027-02-15', '2027-02-18', 'Beachfront sunset resort, surf lessons scheduled'),
(11, 5, 'Reykjavik', 'Iceland', 1, '2027-03-05', '2027-03-08', 'Downtown hotel, 4x4 rental car, Aurora tour booked'),
(12, 5, 'Vik', 'Iceland', 2, '2027-03-09', '2027-03-12', 'South coast hotel, ice cave glacier tour reservation'),
(13, 6, 'La Fortuna', 'Costa Rica', 1, '2027-05-12', '2027-05-16', 'Rainforest lodge, volcano hot springs passes'),
(14, 6, 'Manuel Antonio', 'Costa Rica', 2, '2027-05-17', '2027-05-20', 'Ocean view hotel, national park wildlife guide'),
(15, 7, 'Barcelona', 'Spain', 1, '2027-06-10', '2027-06-14', 'Gothic Quarter hotel, Sagrada Familia tower entry'),
(16, 7, 'Seville', 'Spain', 2, '2027-06-15', '2027-06-18', 'Santa Cruz neighborhood hotel, Flamenco show tickets'),
(17, 8, 'Cape Town', 'South Africa', 1, '2027-08-01', '2027-08-05', 'V&A Waterfront hotel, Table Mountain cableway pass'),
(18, 8, 'Kruger National Park', 'South Africa', 2, '2027-08-06', '2027-08-10', 'Private game reserve lodge, 4x4 open safari vehicle');

-- 3. SEED ACTIVITIES
INSERT INTO stop_activities (id, stop_id, title, category, time_slot, cost, notes, activity_order)
VALUES
(1, 1, 'Eiffel Tower Sunset Summit Tour', 'Sightseeing', '05:00 PM', 45.00, 'Pre-booked elevator summit access with champagne glass', 1),
(2, 1, 'Louvre Museum Masterpieces Walk', 'Culture', '10:00 AM', 30.00, 'Guided walkthrough of Mona Lisa & Winged Victory', 2),
(3, 1, 'Seine River Gourmet Dinner Cruise', 'Food & Drink', '08:00 PM', 95.00, '3-course French dining cruise along illuminated monuments', 3),
(4, 1, 'Montmartre Artists Village & Sacré-Cœur Stroll', 'Sightseeing', '02:00 PM', 15.00, 'Exploring cobblestone lanes and panoramic hilltop views', 4),
(5, 2, 'Colosseum & Roman Forum Fast-Track', 'Sightseeing', '09:30 AM', 40.00, 'Skip-the-line group ticket with arena floor access', 1),
(6, 2, 'Trastevere Food & Wine Walking Tour', 'Food & Drink', '06:30 PM', 75.00, 'Tasting local pasta carbonara, wine, and artisanal gelato', 2),
(7, 2, 'Vatican Museums & Sistine Chapel', 'Culture', '02:00 PM', 55.00, 'Guided tour of St. Peter Basilica and Papal apartments', 3),
(8, 3, 'Shibuya Sky & Open-Air Observatory', 'Sightseeing', '04:00 PM', 25.00, '360-degree observation deck high over Shibuya Crossing', 1),
(9, 3, 'Tsukiji Outer Market Food Crawl', 'Food & Drink', '09:00 AM', 65.00, 'Fresh sushi, wagyu beef skewers, and green tea tasting', 2),
(10, 3, 'Mt. Fuji & Lake Kawaguchi Scenic Excursion', 'Adventure', '08:00 AM', 110.00, 'Full-day bus tour with Mt. Fuji 5th station cable car', 3),
(11, 4, 'Arashiyama Bamboo Grove & Monkey Park', 'Sightseeing', '08:30 AM', 20.00, 'Early morning bamboo forest stroll and monkey sanctuary', 1),
(12, 4, 'Fushimi Inari 10,000 Torii Gates Sunset Hike', 'Culture', '03:30 PM', 0.00, 'Hike up Mount Inari under famous vermilion torii gates', 2),
(13, 4, 'Traditional Gion Tea Ceremony & Kimono', 'Culture', '11:00 AM', 50.00, 'Authentic matcha tea preparation in historical tea house', 3),
(14, 5, 'Dotonbori Street Food Tour (Takoyaki & Okonomiyaki)', 'Food & Drink', '07:00 PM', 40.00, 'Exploring neon-lit street food alleyways', 1),
(15, 5, 'Osaka Castle Park & Historical Museum', 'Sightseeing', '10:00 AM', 15.00, 'Exploring Japanese feudal castle gardens', 2),
(16, 6, 'Lake Zurich Steamboat & Alpine Panorama Cruise', 'Sightseeing', '02:30 PM', 35.00, 'Scenic steamboat ride across Lake Zurich', 1),
(17, 6, 'Old Town Altstadt Chocolate & Fondue Walk', 'Food & Drink', '06:00 PM', 70.00, 'Tasting Swiss artisanal chocolates and traditional fondue', 2),
(18, 7, 'Chapel Bridge & Historic Water Tower Walk', 'Sightseeing', '10:00 AM', 0.00, 'Exploring 14th century covered wooden bridge', 1),
(19, 7, 'Mt. Titlis Glacier Cable Car & Rotair Excursion', 'Adventure', '09:00 AM', 125.00, 'Reaching 3,020m high snow glacier with cliff walk', 2),
(20, 8, 'Gornergrat Railway Matterhorn Viewpoint', 'Sightseeing', '09:30 AM', 90.00, 'Scenic cogwheel train ride with Matterhorn mountain views', 1),
(21, 8, 'Alpine Sledding & Swiss Chalet Dinner', 'Food & Drink', '07:00 PM', 85.00, 'Night sledding followed by cozy chalet fireside dinner', 2),
(22, 9, 'Tegalalang Rice Terraces & Jungle Swing', 'Adventure', '09:00 AM', 35.00, 'Soaring over lush green palm forest valley', 1),
(23, 9, 'Sacred Monkey Forest Sanctuary Walk', 'Sightseeing', '02:00 PM', 10.00, 'Interacting with wild macaques among ancient temple ruins', 2),
(24, 10, 'Tanah Lot Cliffside Temple Sunset Tour', 'Sightseeing', '05:00 PM', 15.00, 'Watching waves crash against sea temple at dusk', 1),
(25, 10, 'Canggu Beach Surf Lesson & Coconut', 'Adventure', '09:00 AM', 30.00, '2-hour beginner surfing lesson with local instructor', 2),
(26, 11, 'Golden Circle Geysir & Gullfoss Waterfall Tour', 'Sightseeing', '08:30 AM', 95.00, 'Visiting Thingvellir National Park, eruption geysers', 1),
(27, 11, 'Blue Lagoon Geothermal Spa & Silica Mask', 'Culture', '03:00 PM', 110.00, 'Relaxing in mineral-rich volcanic geothermal waters', 2),
(28, 12, 'Reynisfjara Black Sand Beach & Basalt Columns', 'Sightseeing', '10:00 AM', 0.00, 'Walking along dramatic black volcanic sands and sea stacks', 1),
(29, 12, 'Katla Ice Cave Guided Glacier Hike', 'Adventure', '01:00 PM', 160.00, 'Exploring blue ice caves inside Myrdalsjokull glacier', 2),
(30, 13, 'Arenal Volcano National Park Lava Trail Hike', 'Sightseeing', '08:00 AM', 25.00, 'Guided trek across ancient lava fields with volcano views', 1),
(31, 13, 'Mistico Hanging Bridges Sloth Canopy Walk', 'Adventure', '11:00 AM', 40.00, 'Suspension bridge walk observing sloths, toucans, monkeys', 2),
(32, 14, 'Manuel Antonio National Park Wildlife Safari', 'Sightseeing', '07:30 AM', 30.00, 'Guided rainforest trail walk to white sand beaches', 1),
(33, 15, 'Sagrada Familia Fast-Track Guided Tower Access', 'Culture', '10:00 AM', 38.00, 'Exploring Gaudi masterpiece basilica towers', 1),
(34, 15, 'Gothic Quarter Tapas & Wine Tasting Walk', 'Food & Drink', '07:30 PM', 65.00, 'Tasting Catalan ham, croquettes, and local wine', 2),
(35, 16, 'Royal Alcazar Palace & Moorish Gardens', 'Culture', '09:30 AM', 20.00, 'Exploring ancient UNESCO World Heritage royal palace', 1),
(36, 16, 'Authentic Flamenco Show in Triana Neighborhood', 'Culture', '08:30 PM', 35.00, 'Passionate Spanish flamenco performance with drink', 2),
(37, 17, 'Table Mountain Aerial Cableway & Summit Walk', 'Sightseeing', '09:00 AM', 30.00, '360-degree rotating cable car ride to mountain summit', 1),
(38, 17, 'Cape Peninsula & Boulders Beach Penguins Tour', 'Sightseeing', '10:00 AM', 55.00, 'Visiting Cape of Good Hope and African penguin colony', 2),
(39, 18, 'Big Five Full-Day Open 4x4 Game Drive Safari', 'Adventure', '06:00 AM', 180.00, 'Tracking lions, leopards, elephants, rhinos, and buffalo', 1),
(40, 18, 'Sunset Bush Dinner & Stargazing Safari', 'Food & Drink', '06:30 PM', 95.00, 'Outdoor boma dinner under African night sky', 2);

-- 4. SEED DESTINATIONS
INSERT INTO destinations (id, name, country, region, image_url, average_cost, cost_index, popularity_score, view_count, visit_count, description)
VALUES 
(1, 'Paris', 'France', 'Europe', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80', 1200.00, '$$$', 4.9, 2450, 680, 'City of lights, iconic Eiffel Tower, Louvre museum, and fine dining.'),
(2, 'Tokyo', 'Japan', 'Asia', 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=600&q=80', 1500.00, '$$$$', 4.9, 2120, 590, 'Ultramodern skyscrapers meet historic temples, Shibuya crossing, and Michelin sushi.'),
(3, 'Rome', 'Italy', 'Europe', 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=600&q=80', 950.00, '$$$', 4.8, 1890, 510, 'Ancient Colosseum ruins, Vatican City, vibrant piazza life, and delicious pasta.'),
(4, 'Bali', 'Indonesia', 'Asia', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=80', 700.00, '$$', 4.7, 1640, 440, 'Tropical beaches, serene cliffside temples, and lush terraced rice paddies.'),
(5, 'Zurich', 'Switzerland', 'Europe', 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=600&q=80', 1800.00, '$$$$', 4.8, 1420, 390, 'Scenic alpine lakes, picturesque Old Town promenade, and Swiss chocolate.'),
(6, 'Kyoto', 'Japan', 'Asia', 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=600&q=80', 1100.00, '$$$', 4.9, 1310, 370, 'Historical imperial capital, golden Buddhist temples, and tranquil bamboo groves.'),
(7, 'Reykjavik', 'Iceland', 'Europe', 'https://images.unsplash.com/photo-1504893524553-b855bce32c67?auto=format&fit=crop&w=600&q=80', 1650.00, '$$$$', 4.9, 1180, 310, 'Gateway to Northern Lights, geothermal hot springs, and volcanic glaciers.'),
(8, 'Cape Town', 'South Africa', 'Africa', 'https://images.unsplash.com/photo-1516426122078-c23e76319801?auto=format&fit=crop&w=600&q=80', 1300.00, '$$$', 4.9, 980, 260, 'Dramatic Table Mountain, coastal vineyards, penguin beaches, and wildlife safari.'),
(9, 'Barcelona', 'Spain', 'Europe', 'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?auto=format&fit=crop&w=600&q=80', 850.00, '$$', 4.8, 890, 240, 'Gaudi Sagrada Familia architecture, Mediterranean beaches, and tapas bars.'),
(10, 'New York', 'United States', 'Americas', 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&w=600&q=80', 1600.00, '$$$$', 4.9, 820, 210, 'Broadway theaters, Empire State Building, Times Square, and Central Park.');

-- 5. SEED ACTIVITIES CATALOG
INSERT INTO activities (id, destination_id, title, category, duration, cost, description, image_url, popularity_score)
VALUES
(1, 1, 'Eiffel Tower Sunset Summit Tour', 'Sightseeing', '2.5 hours', 45.00, 'Elevator access to top floor with champagne glass at sunset', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80', 4.9),
(2, 1, 'Louvre Museum Guided Masterpieces Walk', 'Culture', '3 hours', 30.00, 'Skip-the-line ticket viewing Mona Lisa and Venus de Milo', 'https://images.unsplash.com/photo-1565099824688-e93eb20fe622?auto=format&fit=crop&w=600&q=80', 4.8),
(3, 1, 'Seine River Gourmet Dinner Cruise', 'Food & Drink', '2 hours', 95.00, 'A 3-course French dining cruise along illuminated Paris monuments', 'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?auto=format&fit=crop&w=600&q=80', 4.7),
(4, 2, 'Shibuya Sky & Harajuku Culture Tour', 'Sightseeing', '3 hours', 25.00, '360-degree open-air observation deck overlooking Shibuya Crossing', 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=600&q=80', 4.9),
(5, 2, 'Tokyo Tsukiji Outer Market Food Tour', 'Food & Drink', '2.5 hours', 65.00, 'Fresh sushi, wagyu beef skewers, and green tea tastings', 'https://images.unsplash.com/photo-1535141192574-5d4897c13136?auto=format&fit=crop&w=600&q=80', 4.8),
(6, 2, 'Mt. Fuji & Lake Kawaguchi Day Trip', 'Adventure', '8 hours', 110.00, 'Scenic bus excursion to Fuji 5th station and panoramic cable car', 'https://images.unsplash.com/photo-1490806843957-31f4c9a91c65?auto=format&fit=crop&w=600&q=80', 4.9),
(7, 3, 'Colosseum & Roman Forum Underground Tour', 'Sightseeing', '3.5 hours', 40.00, 'Explore gladiators entrance and ancient ruins with expert historian', 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=600&q=80', 4.9),
(8, 3, 'Trastevere Evening Pasta & Wine Walk', 'Food & Drink', '3 hours', 75.00, 'Authentic Roman carbonara, wine cellars, and artisanal gelato', 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=600&q=80', 4.8),
(9, 4, 'Ubud Rice Terraces & Jungle Swing', 'Adventure', '4 hours', 35.00, 'Lush Tegalalang rice field walk and soaring jungle swing', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=80', 4.7),
(10, 6, 'Kyoto Arashiyama Bamboo Grove & Monkey Park', 'Sightseeing', '3 hours', 20.00, 'Tranquil bamboo forest stroll and Iwatayama monkey sanctuary', 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=600&q=80', 4.9);
