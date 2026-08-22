<?php
require_once 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$userId = isset($data['user_id']) ? (int)$data['user_id'] : 0;
$title = trim($data['title'] ?? '');
$destination = trim($data['destination'] ?? '');
$startDate = trim($data['start_date'] ?? '');
$endDate = trim($data['end_date'] ?? '');
$budget = isset($data['budget']) ? (float)$data['budget'] : 0.0;
$status = trim($data['status'] ?? 'Planned');

if ($userId <= 0 || empty($title) || empty($destination) || empty($startDate) || empty($endDate)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Missing required trip fields."]);
    exit();
}

$stmt = $pdo->prepare("INSERT INTO trips (user_id, title, destination, start_date, end_date, budget, status) VALUES (?, ?, ?, ?, ?, ?, ?)");

if ($stmt->execute([$userId, $title, $destination, $startDate, $endDate, $budget, $status])) {
    $tripId = $pdo->lastInsertId();
    echo json_encode([
        "success" => true,
        "message" => "Trip created successfully!",
        "trip" => [
            "id" => (int)$tripId,
            "user_id" => $userId,
            "title" => $title,
            "destination" => $destination,
            "start_date" => $startDate,
            "end_date" => $endDate,
            "budget" => $budget,
            "status" => $status
        ]
    ]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Failed to create trip."]);
}
?>
