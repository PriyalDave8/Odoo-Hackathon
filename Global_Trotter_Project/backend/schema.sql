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

-- Seed 5 rich trips for Alex Morgan
INSERT INTO trips (id, user_id, title, destination, start_date, end_date, budget, status, description, cover_image_url)
VALUES 
(1, 1, 'Euro Summer Getaway', 'Paris & Rome', '2026-09-10', '2026-09-20', 2500.00, 'Confirmed', 'An exciting 10-day tour across romantic Paris landmarks and historic Roman ruins.', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80'),
(2, 1, 'Japan Autumn Exploration', 'Tokyo & Kyoto', '2026-11-01', '2026-11-12', 3200.00, 'Planned', 'Discovering vibrant Tokyo technology and traditional Kyoto shrines during autumn foliage.', 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=600&q=80'),
(3, 1, 'Swiss Alps Winter Adventure', 'Zurich & Lucerne', '2026-12-15', '2026-12-24', 4100.00, 'Planned', 'Enjoying alpine snowscapes, lake cruises, and world-class Swiss fondue in Zurich and Lucerne.', 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=600&q=80'),
(4, 1, 'Bali Tropical Beach Escape', 'Ubud & Seminyak', '2027-02-10', '2027-02-18', 1800.00, 'Planned', 'Relaxing in tropical villas, visiting cliffside temples, and swinging over lush terraced rice fields.', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=80'),
(5, 1, 'New York East Coast Heritage', 'New York & Boston', '2027-04-05', '2027-04-14', 2900.00, 'Planned', 'Experiencing Broadway, Times Square, and historical freedom trails along the US East Coast.', 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&w=600&q=80');

-- Seed trip city stops
INSERT INTO trip_stops (id, trip_id, city_name, country, stop_order, start_date, end_date, notes)
VALUES
(1, 1, 'Paris', 'France', 1, '2026-09-10', '2026-09-15', 'Hotel in Le Marais, Eiffel Tower summit, Louvre walk'),
(2, 1, 'Rome', 'Italy', 2, '2026-09-16', '2026-09-20', 'Hotel near Piazza Navona, Colosseum, Vatican tour'),
(3, 2, 'Tokyo', 'Japan', 1, '2026-11-01', '2026-11-06', 'Shinjuku hotel, Shibuya Crossing, Tsukiji Market'),
(4, 2, 'Kyoto', 'Japan', 2, '2026-11-07', '2026-11-12', 'Traditional Ryokan in Gion, Bamboo Grove, Fushimi Inari'),
(5, 3, 'Zurich', 'Switzerland', 1, '2026-12-15', '2026-12-19', 'Old Town stroll, Lake Zurich steamboat, Bahnhofstrasse shopping'),
(6, 3, 'Lucerne', 'Switzerland', 2, '2026-12-20', '2026-12-24', 'Chapel Bridge walk, Mt. Titlis cable car excursion'),
(7, 4, 'Ubud', 'Indonesia', 1, '2027-02-10', '2027-02-14', 'Rice terrace villa, Monkey Sanctuary, Spa treatments'),
(8, 4, 'Seminyak', 'Indonesia', 2, '2027-02-15', '2027-02-18', 'Beachfront resort, sunset dining, surfing lessons');

-- Seed stop activities
INSERT INTO stop_activities (id, stop_id, title, category, time_slot, cost, notes, activity_order)
VALUES
(1, 1, 'Eiffel Tower Sunset Summit Tour', 'Sightseeing', '05:00 PM', 45.00, 'Pre-booked elevator summit access with champagne', 1),
(2, 1, 'Louvre Museum Masterpieces Walk', 'Culture', '10:00 AM', 30.00, 'Guided walkthrough of Mona Lisa & Winged Victory', 2),
(3, 1, 'Seine River Gourmet Dinner Cruise', 'Food & Drink', '08:00 PM', 95.00, '3-course French dinner illuminated cruise', 3),
(4, 2, 'Colosseum & Roman Forum Fast-Track', 'Sightseeing', '09:30 AM', 40.00, 'Skip-the-line group ticket with arena floor access', 1),
(5, 2, 'Trastevere Food & Wine Walking Tour', 'Food & Drink', '06:30 PM', 75.00, 'Tasting local pasta, wine, and gelato', 2),
(6, 2, 'Vatican Museums & Sistine Chapel', 'Culture', '02:00 PM', 55.00, 'Guided tour of St. Peter Basilica and Papal apartments', 3),
(7, 3, 'Shibuya Sky & Open Air Deck', 'Sightseeing', '04:00 PM', 25.00, '360-degree observation over Shibuya Crossing', 1),
(8, 3, 'Tsukiji Outer Market Food Tour', 'Food & Drink', '09:00 AM', 65.00, 'Fresh sushi, wagyu skewers, and green tea tasting', 2),
(9, 3, 'Mt. Fuji & Lake Kawaguchi Excursion', 'Adventure', '08:00 AM', 110.00, 'Scenic day tour with cable car ride', 3),
(10, 4, 'Arashiyama Bamboo Grove Walk', 'Sightseeing', '08:30 AM', 20.00, 'Early morning walk through bamboo forest', 1),
(11, 4, 'Fushimi Inari 10,000 Torii Gates Hike', 'Culture', '02:00 PM', 0.00, 'Hike up Mount Inari under vermilion torii gates', 2),
(12, 5, 'Lake Zurich Steamboat Cruise', 'Sightseeing', '02:30 PM', 35.00, 'Panoramic boat ride across Lake Zurich', 1),
(13, 7, 'Tegalalang Rice Terraces & Jungle Swing', 'Adventure', '09:00 AM', 35.00, 'Soaring over lush green palm forest valley', 1);

-- Seed 10 popular destinations for Cities catalog
INSERT INTO destinations (id, name, country, region, image_url, average_cost, cost_index, popularity_score, description)
VALUES 
(1, 'Paris', 'France', 'Europe', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80', 1200.00, '$$$', 4.9, 'City of lights, iconic Eiffel Tower, Louvre museum, and exquisite fine dining.'),
(2, 'Tokyo', 'Japan', 'Asia', 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=600&q=80', 1500.00, '$$$$', 4.9, 'Ultramodern skyscrapers meet historic temples, Shibuya crossing, and Michelin sushi.'),
(3, 'Rome', 'Italy', 'Europe', 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=600&q=80', 950.00, '$$$', 4.8, 'Ancient Colosseum ruins, Vatican City, vibrant piazza life, and delicious pasta.'),
(4, 'Bali', 'Indonesia', 'Asia', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=80', 700.00, '$$', 4.7, 'Tropical beaches, serene cliffside temples, and lush terraced rice paddies.'),
(5, 'Zurich', 'Switzerland', 'Europe', 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=600&q=80', 1800.00, '$$$$', 4.8, 'Scenic alpine lakes, picturesque Old Town promenade, and Swiss chocolate.'),
(6, 'Kyoto', 'Japan', 'Asia', 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=600&q=80', 1100.00, '$$$', 4.9, 'Historical imperial capital, golden Buddhist temples, and tranquil bamboo groves.'),
(7, 'Barcelona', 'Spain', 'Europe', 'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?auto=format&fit=crop&w=600&q=80', 850.00, '$$', 4.8, 'Gaudi Sagrada Familia architecture, Mediterranean beaches, and tapas bars.'),
(8, 'New York', 'United States', 'Americas', 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&w=600&q=80', 1600.00, '$$$$', 4.9, 'Broadway theaters, Empire State Building, Times Square, and Central Park.'),
(9, 'London', 'United Kingdom', 'Europe', 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=600&q=80', 1400.00, '$$$$', 4.8, 'Big Ben, Buckingham Palace, West End theater shows, and historic pubs.'),
(10, 'Sydney', 'Australia', 'Oceania', 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?auto=format&fit=crop&w=600&q=80', 1750.00, '$$$$', 4.9, 'Iconic Sydney Opera House, Harbour Bridge climbing, and Bondi Beach surfing.');

-- Seed Activity search catalog
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
