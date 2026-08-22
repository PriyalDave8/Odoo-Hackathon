CREATE DATABASE IF NOT EXISTS globetrotter_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE globetrotter_db;

DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS user_saved_destinations;
DROP TABLE IF EXISTS stop_activities;
DROP TABLE IF EXISTS trip_stops;
DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS destinations;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    profile_photo_url VARCHAR(255) DEFAULT '',
    language_preference VARCHAR(50) DEFAULT 'English',
    is_admin TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
    best_season VARCHAR(100) DEFAULT 'Spring & Autumn',
    top_attractions TEXT,
    hotel_avg_cost DECIMAL(10,2) DEFAULT 120.00,
    meal_avg_cost DECIMAL(10,2) DEFAULT 45.00,
    description TEXT
);

CREATE TABLE user_saved_destinations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    destination_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE CASCADE,
    UNIQUE KEY user_dest_unique (user_id, destination_id)
);

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
    travel_style VARCHAR(50) DEFAULT 'Cultural Exploration',
    transport_type VARCHAR(50) DEFAULT 'Flight ✈️',
    accommodation_type VARCHAR(50) DEFAULT 'Boutique Hotel 🏨',
    group_size VARCHAR(50) DEFAULT 'Couple (2)',
    currency VARCHAR(10) DEFAULT 'USD ($)',
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

CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    destination_id INT,
    destination_name VARCHAR(100) NOT NULL,
    rating INT NOT NULL DEFAULT 5,
    title VARCHAR(150) NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE SET NULL
);

-- SEED USERS WITH VALID BCRYPT HASH FOR 'password123'
INSERT INTO users (id, name, email, password_hash, profile_photo_url, language_preference, is_admin, created_at) 
VALUES 
(1, 'Alex Morgan', 'alex@globetrotter.com', '$2y$10$HTpC8W1eH9NcSBLZqfMLKOgn3SyQ9lQd9M1cevusOkwzdCJ83GRIi', '', 'English', 1, '2026-01-10 10:00:00'),
(2, 'Sarah Jenkins', 'sarah@globetrotter.com', '$2y$10$HTpC8W1eH9NcSBLZqfMLKOgn3SyQ9lQd9M1cevusOkwzdCJ83GRIi', '', 'English', 0, '2026-02-15 14:30:00'),
(3, 'David Chen', 'david@globetrotter.com', '$2y$10$HTpC8W1eH9NcSBLZqfMLKOgn3SyQ9lQd9M1cevusOkwzdCJ83GRIi', '', 'English', 0, '2026-03-01 09:15:00');

-- 1. SEED 20 RECOMMENDED DESTINATIONS (100% UNIQUE IMAGE URLS)
INSERT INTO destinations (id, name, country, region, image_url, average_cost, cost_index, popularity_score, view_count, visit_count, best_season, top_attractions, hotel_avg_cost, meal_avg_cost, description)
VALUES 
(1, 'Paris', 'France', 'Europe', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80', 1200.00, '$$$', 4.9, 2850, 720, 'May – October (Spring & Autumn)', 'Eiffel Tower Sunset Summit, Louvre Museum Mona Lisa, Seine River Gourmet Cruise, Palace of Versailles, Montmartre & Sacré-Cœur', 150.00, 55.00, 'City of lights, iconic Eiffel Tower, Louvre museum, and fine dining.'),
(2, 'Tokyo', 'Japan', 'Asia', 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=800&q=80', 1500.00, '$$$$', 4.9, 2420, 640, 'March – May & September – November', 'Shibuya Sky Observatory, Tsukiji Outer Market Sushi Crawl, Sensō-ji Temple, Mt. Fuji & Lake Kawaguchi, Akihabara Electric Town', 180.00, 60.00, 'Ultramodern skyscrapers meet historic temples, Shibuya crossing, and Michelin sushi.'),
(3, 'Rome', 'Italy', 'Europe', 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=800&q=80', 950.00, '$$$', 4.8, 2190, 580, 'April – June & September – October', 'Colosseum & Roman Forum, Vatican Museums & Sistine Chapel, Trevi Fountain, Pantheon, Trastevere Food & Wine Walk', 130.00, 45.00, 'Ancient Colosseum ruins, Vatican City, vibrant piazza life, and delicious pasta.'),
(4, 'Bali', 'Indonesia', 'Asia', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=800&q=80', 700.00, '$$', 4.7, 1940, 510, 'April – October (Dry Season)', 'Tegallalang Rice Terraces Jungle Swing, Sacred Monkey Forest, Uluwatu Cliff Temple Fire Dance, Seminyak Beach Clubs', 85.00, 25.00, 'Tropical beaches, serene cliffside temples, and lush terraced rice paddies.'),
(5, 'Zurich', 'Switzerland', 'Europe', 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80', 1800.00, '$$$$', 4.8, 1720, 430, 'December – February (Ski) & June – August', 'Lake Zurich Promenade, Bahnhofstrasse Shopping, Old Town Altstadt, Mt. Titlis Cable Car, Lindt Home of Chocolate', 210.00, 75.00, 'Scenic alpine lakes, picturesque Old Town promenade, and Swiss chocolate.'),
(6, 'Kyoto', 'Japan', 'Asia', 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=800&q=80', 1100.00, '$$$', 4.9, 1510, 410, 'March – May (Cherry Blossom) & November', 'Fushimi Inari 10,000 Torii Gates, Kinkaku-ji Golden Pavilion, Arashiyama Bamboo Grove, Traditional Gion Tea Ceremony', 140.00, 50.00, 'Historical imperial capital, golden Buddhist temples, and tranquil bamboo groves.'),
(7, 'Reykjavik', 'Iceland', 'Europe', 'https://images.unsplash.com/photo-1504893524553-b855bce32c67?auto=format&fit=crop&w=800&q=80', 1650.00, '$$$$', 4.9, 1380, 360, 'September – March (Northern Lights)', 'Blue Lagoon Geothermal Retreat, Golden Circle Geysers, Gullfoss Waterfall, Vik Black Sand Beach, Hallgrímskirkja', 190.00, 65.00, 'Gateway to Northern Lights, geothermal hot springs, and volcanic glaciers.'),
(8, 'London', 'United Kingdom', 'Europe', 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=800&q=80', 1400.00, '$$$$', 4.9, 1290, 340, 'May – September', 'Big Ben & Parliament, British Museum, Tower Bridge, West End Musicals, Buckingham Palace Guard Change', 170.00, 55.00, 'Big Ben, West End theater district, Buckingham Palace, and world-class museums.'),
(9, 'New York', 'United States', 'Americas', 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&w=800&q=80', 1600.00, '$$$$', 4.9, 1210, 310, 'September – November & December (Holidays)', 'Empire State Observatory, Broadway Musicals, Times Square, Central Park Stroll, Statue of Liberty Ferry', 195.00, 60.00, 'Broadway theaters, Empire State Building, Times Square, and Central Park.'),
(10, 'Barcelona', 'Spain', 'Europe', 'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?auto=format&fit=crop&w=800&q=80', 850.00, '$$', 4.8, 1150, 290, 'May – June & September – October', 'Sagrada Família Basilica, Park Güell Gaudi Architecture, Gothic Quarter Alleys, Barceloneta Beach, Tapas Crawl', 115.00, 40.00, 'Gaudi Sagrada Familia architecture, Mediterranean beaches, and tapas bars.'),
(11, 'Sydney', 'Australia', 'Oceania', 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?auto=format&fit=crop&w=800&q=80', 1700.00, '$$$$', 4.9, 1080, 270, 'September – November & February – April', 'Sydney Opera House Guided Tour, Harbour Bridge Climb, Bondi to Coogee Coastal Walk, Darling Harbour, Taronga Zoo', 185.00, 58.00, 'Sydney Opera House, Harbour Bridge, Bondi Beach surfing, and coastal walks.'),
(12, 'Dubai', 'United Arab Emirates', 'Middle East', 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=800&q=80', 1900.00, '$$$$', 4.8, 1020, 250, 'November – March', 'Burj Khalifa 148th Floor Deck, Luxury Desert 4x4 Safari, Dubai Mall Aquarium, Palm Jumeirah, Marina Yacht Cruise', 210.00, 65.00, 'Burj Khalifa, luxury desert safari, palm islands, and futuristic shopping malls.'),
(13, 'Cape Town', 'South Africa', 'Africa', 'https://images.unsplash.com/photo-1516426122078-c23e76319801?auto=format&fit=crop&w=800&q=80', 1300.00, '$$$', 4.9, 980, 240, 'October – April', 'Table Mountain Aerial Cableway, Boulders Beach Penguins, Cape of Good Hope, Stellenbosch Wine Tasting, V&A Waterfront', 135.00, 45.00, 'Dramatic Table Mountain, coastal vineyards, penguin beaches, and wildlife safari.'),
(14, 'Singapore', 'Singapore', 'Asia', 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?auto=format&fit=crop&w=800&q=80', 1450.00, '$$$$', 4.9, 940, 230, 'November – January & June – July', 'Gardens by the Bay Light Show, Marina Bay Sands Infinity Pool, Jewel Changi Waterfall, Chinatown Hawker Feast', 165.00, 48.00, 'Gardens by the Bay, Marina Bay Sands infinity pool, and hawker street food.'),
(15, 'Amsterdam', 'Netherlands', 'Europe', 'https://images.unsplash.com/photo-1512470876302-972faa2aa9a4?auto=format&fit=crop&w=800&q=80', 1150.00, '$$$', 4.8, 890, 210, 'April – May (Tulips) & September – November', 'Canal Cruise by Evening, Van Gogh Museum, Anne Frank House, Keukenhof Tulip Gardens, Jordaan District Biking', 140.00, 50.00, 'Picturesque canal houses, Van Gogh museum, historic windmills, and bicycle routes.'),
(16, 'Prague', 'Czech Republic', 'Europe', 'https://images.unsplash.com/photo-1541849546-216549ae216d?auto=format&fit=crop&w=800&q=80', 800.00, '$$', 4.9, 850, 195, 'May – September & December (Christmas Markets)', 'Charles Bridge Sunrise Stroll, Prague Castle Complex, Astronomical Clock Square, Vltava River Boat Tour', 95.00, 35.00, 'Fairy-tale gothic architecture, medieval Astronomical Clock, Charles Bridge, and famous Czech breweries.'),
(17, 'Vienna', 'Austria', 'Europe', 'https://images.unsplash.com/photo-1516550893923-42d28e5677af?auto=format&fit=crop&w=800&q=80', 1250.00, '$$$', 4.8, 810, 185, 'April – October & December (Palace Markets)', 'Schönbrunn Palace Gardens, St. Stephen Cathedral, Hofburg Imperial Palace, Vienna State Opera, Classical Concert', 145.00, 50.00, 'Imperial palaces, grand classical opera houses, Sachertorte cafe culture, and Danube riverfront.'),
(18, 'Seoul', 'South Korea', 'Asia', 'https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=800&q=80', 1180.00, '$$$', 4.9, 790, 175, 'March – May (Cherry Blossom) & September – November', 'Gyeongbokgung Palace Hanbok Walk, N Seoul Tower Sunset, Myeongdong Street Food Night Market, Bukchon Hanok Village', 125.00, 40.00, 'Futuristic K-pop metropolis, ancient Joseon dynasty palaces, vibrant night markets, and Korean BBQ.'),
(19, 'Bangkok', 'Thailand', 'Asia', 'https://images.unsplash.com/photo-1508009603885-50cf7c579365?auto=format&fit=crop&w=800&q=80', 650.00, '$', 4.8, 760, 165, 'November – February (Cool & Dry)', 'Grand Palace & Emerald Buddha, Wat Arun Temple of Dawn, Chao Phraya River Longtail Boat, Floating Market Crawl', 65.00, 20.00, 'Ornate golden temples, bustling street food stalls, riverboat water taxis, and vibrant tuk-tuk nightlife.'),
(20, 'Santorini', 'Greece', 'Europe', 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?auto=format&fit=crop&w=800&q=80', 1750.00, '$$$$', 4.9, 740, 155, 'Late April – October', 'Oia Sunset Cliffside View, Fira to Oia Coastal Hike, Red Beach Volcanic Sands, Private Catamaran Sunset Cruise', 220.00, 70.00, 'Whitewashed cliffside villas, iconic blue-domed churches, Aegean sea sunsets, and volcanic beaches.');

-- 2. SEED 8 TRIPS (100% UNIQUE IMAGE URLS FOR EACH TRIP)
INSERT INTO trips (id, user_id, title, destination, start_date, end_date, budget, transport_cost, hotel_cost, meal_cost, travel_style, transport_type, accommodation_type, group_size, currency, share_token, status, description, cover_image_url)
VALUES 
(1, 1, 'Euro Summer Getaway', 'Paris & Rome', '2026-09-10', '2026-09-20', 2500.00, 650.00, 1100.00, 550.00, 'Cultural Exploration 🏛️', 'Flight ✈️', 'Boutique Hotel 🏨', 'Couple (2)', 'USD ($)', 'share_euro_summer_2026', 'Confirmed', 'An exciting 10-day tour across romantic Paris landmarks and historic Roman ruins.', 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?auto=format&fit=crop&w=800&q=80'),
(2, 1, 'Japan Autumn Exploration', 'Tokyo, Kyoto & Osaka', '2026-11-01', '2026-11-12', 3500.00, 850.00, 1400.00, 700.00, 'Food & Culinary Tour 🍣', 'High-Speed Train 🚆', 'Luxury Ryokan 🎋', 'Couple (2)', 'USD ($)', 'share_japan_autumn_2026', 'Planned', 'Discovering vibrant Tokyo technology, traditional Kyoto shrines, and Osaka food stalls during autumn foliage.', 'https://images.unsplash.com/photo-1492571350019-22de08371fd3?auto=format&fit=crop&w=800&q=80'),
(3, 1, 'Swiss Alps Winter Wonderland', 'Zurich, Lucerne & Zermatt', '2026-12-15', '2026-12-24', 4500.00, 950.00, 2100.00, 900.00, 'High Adventure 🏔️', 'Rental Car 🚗', 'Alpine Chalet ❄️', 'Family (4)', 'USD ($)', 'share_swiss_alps_2026', 'Planned', 'Enjoying alpine snowscapes, glacier cable cars, lake cruises, and authentic Swiss fondue.', 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80'),
(4, 1, 'Bali Tropical Beach & Temple Escape', 'Ubud & Seminyak', '2027-02-10', '2027-02-18', 1800.00, 500.00, 750.00, 350.00, 'Relaxing Beach Escape 🏖️', 'Flight ✈️', 'Private Pool Villa 🏝️', 'Couple (2)', 'USD ($)', 'share_bali_escape_2027', 'Planned', 'Relaxing in private pool villas, visiting cliffside temples, and swinging over lush terraced rice fields.', 'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?auto=format&fit=crop&w=800&q=80'),
(5, 1, 'Iceland Northern Lights & Glaciers', 'Reykjavik & Vik', '2027-03-05', '2027-03-12', 3600.00, 750.00, 1600.00, 650.00, 'Nature & Aurora Chasing 🌌', 'Rental Car 🚗', 'Boutique Lodge 🏡', 'Group of Friends (4)', 'USD ($)', 'share_iceland_lights_2027', 'Planned', 'Chasing the Aurora Borealis, soaking in the Blue Lagoon, and exploring ice caves on black sand beaches.', 'https://images.unsplash.com/photo-1517411032315-54ef2cb783bb?auto=format&fit=crop&w=800&q=80'),
(6, 2, 'Costa Rica Rainforest Safari', 'La Fortuna & Manuel Antonio', '2027-05-12', '2027-05-20', 2200.00, 450.00, 950.00, 400.00, 'Wildlife Safari 🐒', 'Flight ✈️', 'Rainforest Lodge 🌿', 'Solo Traveler 🎒', 'USD ($)', 'share_costa_rica_2027', 'Planned', 'Hiking active volcanoes and canopy hanging bridges.', 'https://images.unsplash.com/photo-1518638150340-f706e86654de?auto=format&fit=crop&w=800&q=80'),
(7, 2, 'Spanish Tapas & Flamenco Tour', 'Barcelona & Seville', '2027-06-10', '2027-06-18', 2800.00, 600.00, 1200.00, 500.00, 'Food & Culture 🍷', 'High-Speed Train 🚆', 'Boutique Hotel 🏨', 'Couple (2)', 'EUR (€)', 'share_spain_tapas_2027', 'Planned', 'Experiencing Sagrada Familia Gaudi architecture and authentic flamenco.', 'https://images.unsplash.com/photo-15115276670-4d36f6d21394?auto=format&fit=crop&w=800&q=80'),
(8, 3, 'African Big Five Safari & Cape Town', 'Cape Town & Kruger', '2027-08-01', '2027-08-10', 4800.00, 1100.00, 2200.00, 800.00, 'Wildlife Safari 🦁', 'Flight ✈️', 'Game Lodge 🛖', 'Family (4)', 'USD ($)', 'share_africa_safari_2027', 'Planned', 'Riding Table Mountain cableway and tracking the Big Five on safari.', 'https://images.unsplash.com/photo-1516426122078-c23e76319801?auto=format&fit=crop&w=800&q=80');

-- 3. SEED CITY STOPS
INSERT INTO trip_stops (id, trip_id, city_name, country, stop_order, start_date, end_date, notes)
VALUES
(1, 1, 'Paris', 'France', 1, '2026-09-10', '2026-09-15', 'Boutique hotel in Le Marais district, museum passes reserved'),
(2, 1, 'Rome', 'Italy', 2, '2026-09-16', '2026-09-20', 'Hotel near Piazza Navona, Colosseum fast-track tickets'),
(3, 2, 'Tokyo', 'Japan', 1, '2026-11-01', '2026-11-05', 'Shinjuku skyscraper hotel, Suica transit cards ready'),
(4, 2, 'Kyoto', 'Japan', 2, '2026-11-06', '2026-11-09', 'Traditional Ryokan in Gion, private tea ceremony reservation'),
(5, 2, 'Osaka', 'Japan', 3, '2026-11-10', '2026-11-12', 'Hotel near Dotonbori food district'),
(6, 3, 'Zurich', 'Switzerland', 1, '2026-12-15', '2026-12-17', 'Lakefront hotel, Old Town walking route planned'),
(7, 3, 'Lucerne', 'Switzerland', 2, '2026-12-18', '2026-12-21', 'Chapel Bridge hotel, Mt. Titlis cable car tickets'),
(8, 3, 'Zermatt', 'Switzerland', 3, '2026-12-22', '2026-12-24', 'Car-free chalet village, Matterhorn Gornergrat railway'),
(9, 4, 'Ubud', 'Indonesia', 1, '2027-02-10', '2027-02-14', 'Private jungle villa near Monkey Forest'),
(10, 4, 'Seminyak', 'Indonesia', 2, '2027-02-15', '2027-02-18', 'Beachfront resort villa, sunset beach club reserved'),
(11, 5, 'Reykjavik', 'Iceland', 1, '2027-03-05', '2027-03-08', 'Boutique city center hotel, Blue Lagoon spa access booked'),
(12, 5, 'Vik', 'Iceland', 2, '2027-03-09', '2027-03-12', 'Country lodge near Black Sand Beach, Aurora chasing spot'),
(13, 6, 'La Fortuna', 'Costa Rica', 1, '2027-05-12', '2027-05-16', 'Eco-lodge near Arenal Volcano thermal springs'),
(14, 6, 'Manuel Antonio', 'Costa Rica', 2, '2027-05-17', '2027-05-20', 'Pacific rainforest resort near national park beaches'),
(15, 7, 'Barcelona', 'Spain', 1, '2027-06-10', '2027-06-14', 'Gothic Quarter boutique hotel, Sagrada Familia priority pass'),
(16, 8, 'Cape Town', 'South Africa', 1, '2027-08-01', '2027-08-05', 'V&A Waterfront hotel, Table Mountain cableway reserved');

-- 4. SEED ITEMIZATION OF DAY-WISE ACTIVITIES FOR ALL STOPS
INSERT INTO stop_activities (id, stop_id, title, category, time_slot, cost, notes, activity_order)
VALUES
-- Stop 1: Paris
(1, 1, 'Eiffel Tower Sunset Summit Tour', 'Sightseeing', '05:00 PM', 45.00, 'Pre-booked elevator summit access with champagne glass at sunset', 1),
(2, 1, 'Louvre Museum Masterpieces Walk', 'Culture', '10:00 AM', 30.00, 'Guided walkthrough viewing Mona Lisa & Winged Victory', 2),
(3, 1, 'Seine River Gourmet Dinner Cruise', 'Food & Drink', '08:00 PM', 95.00, '3-course French dining cruise along illuminated Paris monuments', 3),
(4, 1, 'Montmartre Artists Village & Sacré-Cœur Stroll', 'Sightseeing', '02:00 PM', 15.00, 'Exploring cobblestone lanes and panoramic hilltop views', 4),
(5, 1, 'Palace of Versailles Guided Gardens Tour', 'Culture', '09:00 AM', 35.00, 'Explore Hall of Mirrors and royal fountains', 5),

-- Stop 2: Rome
(6, 2, 'Colosseum & Roman Forum Fast-Track', 'Sightseeing', '09:30 AM', 40.00, 'Skip-the-line group ticket with arena floor access', 1),
(7, 2, 'Trastevere Food & Wine Walking Tour', 'Food & Drink', '06:30 PM', 75.00, 'Tasting local pasta carbonara, wine, and artisanal gelato', 2),
(8, 2, 'Vatican Museums & Sistine Chapel', 'Culture', '02:00 PM', 55.00, 'Guided tour of St. Peter Basilica and Papal apartments', 3),
(9, 2, 'Trevi Fountain & Spanish Steps Evening Walk', 'Sightseeing', '08:30 PM', 0.00, 'Tossing coin into Trevi Fountain and night gelato stroll', 4),

-- Stop 3: Tokyo
(10, 3, 'Shibuya Sky & Open-Air Observatory', 'Sightseeing', '04:00 PM', 25.00, '360-degree observation deck high over Shibuya Crossing', 1),
(11, 3, 'Tsukiji Outer Market Food Crawl', 'Food & Drink', '09:00 AM', 65.00, 'Fresh sushi, wagyu beef skewers, and green tea tasting', 2),
(12, 3, 'Mt. Fuji & Lake Kawaguchi Scenic Excursion', 'Adventure', '08:00 AM', 110.00, 'Full-day bus tour with Mt. Fuji 5th station cable car', 3),

-- Stop 4: Kyoto
(13, 4, 'Arashiyama Bamboo Grove & Monkey Park', 'Sightseeing', '08:30 AM', 20.00, 'Early morning bamboo forest stroll and monkey sanctuary', 1),
(14, 4, 'Fushimi Inari 10,000 Torii Gates Sunset Hike', 'Culture', '03:30 PM', 0.00, 'Hike up Mount Inari under famous vermilion torii gates', 2),
(15, 4, 'Traditional Gion Tea Ceremony & Kimono', 'Culture', '11:00 AM', 50.00, 'Authentic matcha tea preparation in historical tea house', 3),

-- Stop 5: Osaka
(16, 5, 'Dotonbori Street Food & Takoyaki Crawl', 'Food & Drink', '07:00 PM', 40.00, 'Sampling famous octopus balls, okonomiyaki, and neon nightlife', 1),
(17, 5, 'Osaka Castle Park & Museum Tour', 'Culture', '10:30 AM', 15.00, 'Exploring feudal samurai history and castle observation deck', 2),

-- Stop 6: Zurich
(18, 6, 'Zurich Old Town & Lakefront Boat Promenade', 'Sightseeing', '10:00 AM', 25.00, 'Guided walk through medieval alleys and lake cruise', 1),
(19, 6, 'Lindt Home of Chocolate Tasting Experience', 'Food & Drink', '02:30 PM', 30.00, 'Interactive chocolate fountain walkthrough and masterclass', 2),

-- Stop 7: Lucerne
(20, 7, 'Mt. Titlis Glacier Cable Car & Ice Flyer', 'Adventure', '09:00 AM', 105.00, 'Revolving cable car, cliff walk suspension bridge, and glacier park', 1),
(21, 7, 'Historic Chapel Bridge & Old Town Stroll', 'Sightseeing', '04:00 PM', 0.00, 'Walking across 14th-century wooden Chapel Bridge', 2),

-- Stop 8: Zermatt
(22, 8, 'Gornergrat Cogwheel Railway to Matterhorn', 'Sightseeing', '08:30 AM', 95.00, 'Panoramic mountain train with Matterhorn reflection lake', 1),
(23, 8, 'Authentic Alpine Cheese Fondue Dinner', 'Food & Drink', '07:30 PM', 60.00, 'Traditional Swiss fondue and white wine in cozy chalet', 2),

-- Stop 9: Ubud
(24, 9, 'Tegallalang Rice Terrace Swing & Trek', 'Sightseeing', '08:00 AM', 25.00, 'Iconic jungle swing over terraced green rice paddies', 1),
(25, 9, 'Sacred Monkey Forest Sanctuary Walk', 'Nature', '02:00 PM', 10.00, 'Interacting with wild macaque monkeys in ancient jungle temple', 2),

-- Stop 10: Seminyak
(26, 10, 'Uluwatu Cliffside Temple & Kecak Fire Dance', 'Culture', '05:30 PM', 35.00, 'Sunset cliffside temple views with dramatic traditional fire dance', 1),
(27, 10, 'Seminyak Beachfront Sunset Club & Cocktails', 'Relaxation', '07:00 PM', 50.00, 'Lounge daybeds and ocean view dining', 2),

-- Stop 11: Reykjavik
(28, 11, 'Blue Lagoon Geothermal Retreat & Spa', 'Relaxation', '11:00 AM', 120.00, 'Soaking in mineral-rich milky blue waters with silica face mask', 1),
(29, 11, 'Golden Circle Geysers & Gullfoss Waterfall', 'Adventure', '08:30 AM', 85.00, 'Thingvellir rift valley, Strokkur exploding geyser, and waterfall', 2),

-- Stop 12: Vik
(30, 12, 'Reynisfjara Black Sand Beach & Aurora Hunt', 'Adventure', '09:30 PM', 75.00, 'Basalt sea stacks and night Northern Lights jeep tour', 1),

-- Stop 13: La Fortuna
(31, 13, 'Arenal Volcano Rainforest Hanging Bridges', 'Adventure', '08:00 AM', 45.00, 'Canopy walking tour spotting sloths, toucans, and monkeys', 1),
(32, 13, 'Tabacon Volcanic Hot Springs Thermal Soak', 'Relaxation', '05:00 PM', 80.00, 'Natural jungle river hot springs with buffet dinner', 2),

-- Stop 14: Manuel Antonio
(33, 14, 'Manuel Antonio National Park Beach Safari', 'Nature', '07:30 AM', 30.00, 'Guided wildlife hike ending on pristine white sand Pacific beach', 1),

-- Stop 15: Barcelona
(34, 15, 'Sagrada Familia Fast-Track Tower Access', 'Culture', '10:00 AM', 40.00, 'Gaudi masterpiece basilica tour with tower panoramic climb', 1),
(35, 15, 'El Born Tapas & Sangria Night Crawl', 'Food & Drink', '08:00 PM', 65.00, 'Tasting Iberian ham, patatas bravas, and local wines', 2),

-- Stop 16: Cape Town
(36, 16, 'Table Mountain Aerial Cableway Summit', 'Sightseeing', '09:00 AM', 35.00, '360-degree rotating cable car climb to flat mountain plateau', 1),
(37, 16, 'Boulders Beach Penguin Colony Visit', 'Nature', '02:00 PM', 20.00, 'Walking along boardwalks alongside wild African penguins', 2);

-- 5. SEED REVIEWS AND RATINGS
INSERT INTO reviews (id, user_id, destination_id, destination_name, rating, title, comment, created_at)
VALUES
(1, 1, 1, 'Paris, France', 5, 'Unforgettable Eiffel Tower & Louvre Experience!', 'Paris was absolutely magical. The sunset summit tour of the Eiffel Tower and the Seine river dinner cruise made our Euro Summer getaway unforgettable.', '2026-08-01 12:00:00'),
(2, 2, 2, 'Tokyo, Japan', 5, 'Best Culinary & Tech City on Earth', 'Tokyo surpassed all expectations! The Tsukiji outer market sushi crawl and Shibuya Sky observation deck were highlights of a lifetime.', '2026-08-05 15:30:00'),
(3, 3, 3, 'Rome, Italy', 5, 'Ancient Ruins & Mind-Blowing Pasta', 'Walking through the Colosseum and exploring Trastevere night food tours was top tier. GlobeTrotter itinerary builder saved us hours of planning!', '2026-08-10 09:45:00'),
(4, 2, 4, 'Bali, Indonesia', 4, 'Serene Beaches & Rice Paddy Swings', 'Beautiful villa stay in Seminyak and serene temple visits in Ubud. Super easy to customize city stops on the platform!', '2026-08-12 18:20:00'),
(5, 1, 5, 'Zurich, Switzerland', 5, 'Picturesque Alpine Scenery', 'Pristine mountain vistas, scenic lake cruises, and delicious Swiss fondue. Highly recommended for couples and families alike!', '2026-08-15 11:10:00'),
(6, 3, 8, 'London, United Kingdom', 5, 'Iconic Museums & West End Shows', 'West End theater shows and historic Big Ben walk were fabulous. Copying the itinerary directly into my account was effortless!', '2026-08-18 16:40:00');

-- 6. SEED SAVED DESTINATIONS FOR ALEX MORGAN
INSERT INTO user_saved_destinations (user_id, destination_id) VALUES (1, 1), (1, 2), (1, 5), (1, 8), (1, 12), (1, 16), (1, 20);

-- 7. SEED ACTIVITIES CATALOG (100% UNIQUE IMAGE URLS)
INSERT INTO activities (id, destination_id, title, category, duration, cost, description, image_url, popularity_score)
VALUES
(1, 1, 'Eiffel Tower Sunset Summit Tour', 'Sightseeing', '2.5 hours', 45.00, 'Elevator access to top floor with champagne glass at sunset', 'https://images.unsplash.com/photo-1543349689-9a4d426bee8e?auto=format&fit=crop&w=800&q=80', 4.9),
(2, 1, 'Louvre Museum Guided Masterpieces Walk', 'Culture', '3 hours', 30.00, 'Skip-the-line ticket viewing Mona Lisa and Venus de Milo', 'https://images.unsplash.com/photo-1565099824688-e93eb20fe622?auto=format&fit=crop&w=800&q=80', 4.8),
(3, 1, 'Seine River Gourmet Dinner Cruise', 'Food & Drink', '2 hours', 95.00, 'A 3-course French dining cruise along illuminated Paris monuments', 'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?auto=format&fit=crop&w=800&q=80', 4.7),
(4, 2, 'Shibuya Sky & Harajuku Culture Tour', 'Sightseeing', '3 hours', 25.00, '360-degree open-air observation deck overlooking Shibuya Crossing', 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80', 4.9),
(5, 2, 'Tokyo Tsukiji Outer Market Food Tour', 'Food & Drink', '2.5 hours', 65.00, 'Fresh sushi, wagyu beef skewers, and green tea tastings', 'https://images.unsplash.com/photo-1535141192574-5d4897c13136?auto=format&fit=crop&w=800&q=80', 4.8);
