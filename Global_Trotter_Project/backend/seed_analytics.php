<?php
require_once 'config.php';

echo "Seeding analytics and stop activities...\n";

// 1. Ensure stop_activities has records
$check = $pdo->query("SELECT COUNT(*) FROM stop_activities")->fetchColumn();
if ($check == 0) {
    $activities = [
        [1, 'Eiffel Tower Summit Access', 'Sightseeing', 120.00, '09:00', '12:00'],
        [1, 'Louvre Museum Guided Tour', 'Cultural', 85.00, '13:00', '16:00'],
        [1, 'Seine River Dinner Cruise', 'Dining', 150.00, '19:00', '21:30'],
        [2, 'Colosseum & Roman Forum Tour', 'Cultural', 95.00, '10:00', '13:00'],
        [2, 'Trastevere Food Tasting Hike', 'Dining', 75.00, '17:00', '20:00'],
        [3, 'Mount Fuji Day Express Trip', 'Adventure', 180.00, '08:00', '17:00'],
        [3, 'Shibuya Sky & Harajuku Walk', 'Sightseeing', 45.00, '18:00', '21:00'],
        [4, 'Swiss Alps Scenic Train Pass', 'Transport', 210.00, '08:30', '16:00'],
        [4, 'Zurich Old Town Food Tour', 'Dining', 110.00, '12:00', '15:00'],
    ];

    $stmt = $pdo->prepare("INSERT INTO stop_activities (trip_stop_id, title, category, cost, start_time, end_time) VALUES (?, ?, ?, ?, ?, ?)");
    foreach ($activities as $act) {
        $stmt->execute($act);
    }
    echo "Inserted 9 stop activities!\n";
} else {
    echo "stop_activities already has $check rows.\n";
}

// 2. Ensure view_count and visit_count in destinations are non-zero
$pdo->exec("UPDATE destinations SET view_count = 1240, visit_count = 450 WHERE id = 1");
$pdo->exec("UPDATE destinations SET view_count = 980, visit_count = 380 WHERE id = 2");
$pdo->exec("UPDATE destinations SET view_count = 1450, visit_count = 520 WHERE id = 3");
$pdo->exec("UPDATE destinations SET view_count = 890, visit_count = 310 WHERE id = 4");
$pdo->exec("UPDATE destinations SET view_count = 1120, visit_count = 410 WHERE id = 5");
$pdo->exec("UPDATE destinations SET view_count = 780, visit_count = 290 WHERE id = 6");

echo "Destinations view/visit stats updated successfully!\n";
