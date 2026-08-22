<?php
require_once 'config.php';

$userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;

if ($userId <= 0) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Valid user_id is required."]);
    exit();
}

// 1. Fetch User Trips
$stmt = $pdo->prepare("SELECT id, title, destination, start_date, end_date, budget, status, created_at FROM trips WHERE user_id = ? ORDER BY created_at DESC");
$stmt->execute([$userId]);
$trips = $stmt->fetchAll();

// Formatting trips data
$formattedTrips = array_map(function($trip) {
    return [
        "id" => (int)$trip['id'],
        "title" => $trip['title'],
        "destination" => $trip['destination'],
        "start_date" => $trip['start_date'],
        "end_date" => $trip['end_date'],
        "budget" => (float)$trip['budget'],
        "status" => $trip['status']
    ];
}, $trips);

// 2. Compute Summary Stats
$totalTrips = count($formattedTrips);
$totalBudget = 0;
$activeTrips = 0;

foreach ($formattedTrips as $t) {
    $totalBudget += $t['budget'];
    if ($t['status'] === 'Planned' || $t['status'] === 'Active') {
        $activeTrips++;
    }
}

// 3. Fetch Recommended Destinations
$destStmt = $pdo->query("SELECT id, name, country, image_url, average_cost, description FROM destinations LIMIT 6");
$destinations = $destStmt->fetchAll();

$formattedDestinations = array_map(function($d) {
    return [
        "id" => (int)$d['id'],
        "name" => $d['name'],
        "country" => $d['country'],
        "image_url" => $d['image_url'],
        "average_cost" => (float)$d['average_cost'],
        "description" => $d['description']
    ];
}, $destinations);

echo json_encode([
    "success" => true,
    "stats" => [
        "total_trips" => $totalTrips,
        "active_trips" => $activeTrips,
        "total_budget" => $totalBudget
    ],
    "trips" => $formattedTrips,
    "recommended_destinations" => $formattedDestinations
]);
?>
