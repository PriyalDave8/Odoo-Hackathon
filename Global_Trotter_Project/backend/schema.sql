CREATE DATABASE IF NOT EXISTS globetrotter_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE globetrotter_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS trips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'Planned',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS destinations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    image_url VARCHAR(255),
    average_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    description TEXT
);

-- Seed initial test user if not exists
INSERT INTO users (id, name, email, password_hash) 
VALUES (1, 'Alex Morgan', 'alex@globetrotter.com', '$2y$10$e8p2UeIqNkW43H2sWk7e9.bN4V4x5Z4W4y5Z4W4y5Z4W4y5Z4W4y5')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Seed sample trips for Alex Morgan if not exists
INSERT INTO trips (id, user_id, title, destination, start_date, end_date, budget, status)
VALUES 
(1, 1, 'Euro Summer Getaway', 'Paris, France', '2026-09-10', '2026-09-20', 2500.00, 'Planned'),
(2, 1, 'Japan Autumn Exploration', 'Tokyo, Japan', '2026-11-01', '2026-11-12', 3200.00, 'Planned')
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- Seed sample popular destinations if table empty
INSERT INTO destinations (id, name, country, image_url, average_cost, description)
VALUES 
(1, 'Paris', 'France', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80', 1200.00, 'City of lights, iconic landmarks, art and cuisine.'),
(2, 'Tokyo', 'Japan', 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=600&q=80', 1500.00, 'Ultramodern skyscrapers meets historic temples and world-class food.'),
(3, 'Rome', 'Italy', 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=600&q=80', 950.00, 'Ancient ruins, vibrant street life, and rich cultural heritage.'),
(4, 'Bali', 'Indonesia', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=80', 700.00, 'Tropical beaches, serene temples, and lush terraced rice fields.')
ON DUPLICATE KEY UPDATE name=VALUES(name);
