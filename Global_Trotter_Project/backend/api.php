<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';
$data = json_decode(file_get_contents('php://input'), true) ?? [];

// 1. AUTHENTICATION
if ($action === 'register' && $method === 'POST') {
    $name = trim($data['name'] ?? '');
    $email = trim($data['email'] ?? '');
    $password = $data['password'] ?? '';

    if (empty($name) || empty($email) || empty($password)) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "All fields are required."]);
        exit();
    }

    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Email is already registered."]);
        exit();
    }

    $hash = password_hash($password, PASSWORD_BCRYPT);
    $stmt = $pdo->prepare("INSERT INTO users (name, email, password_hash, profile_photo_url, language_preference, is_admin) VALUES (?, ?, ?, ?, ?, 0)");
    $photoUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80';
    if ($stmt->execute([$name, $email, $hash, $photoUrl, 'English'])) {
        $newId = (int)$pdo->lastInsertId();
        echo json_encode([
            "success" => true,
            "message" => "Registration successful!",
            "user" => [
                "id" => $newId,
                "name" => $name,
                "email" => $email,
                "profile_photo_url" => $photoUrl,
                "language_preference" => "English",
                "is_admin" => 0
            ]
        ]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Registration failed."]);
    }
    exit();
}

if ($action === 'login' && $method === 'POST') {
    $email = trim($data['email'] ?? '');
    $password = $data['password'] ?? '';

    if (empty($email) || empty($password)) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Email and password are required."]);
        exit();
    }

    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['password_hash'])) {
        echo json_encode([
            "success" => true,
            "message" => "Login successful!",
            "user" => [
                "id" => (int)$user['id'],
                "name" => $user['name'],
                "email" => $user['email'],
                "profile_photo_url" => $user['profile_photo_url'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                "language_preference" => $user['language_preference'] ?? 'English',
                "is_admin" => (int)($user['is_admin'] ?? 0)
            ]
        ]);
    } else {
        http_response_code(401);
        echo json_encode(["success" => false, "message" => "Invalid email or password."]);
    }
    exit();
}

if ($action === 'reset_password' && $method === 'POST') {
    $email = trim($data['email'] ?? '');
    $newPassword = trim($data['new_password'] ?? '');

    if (empty($email) || empty($newPassword)) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Email and new password are required."]);
        exit();
    }

    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if (!$user) {
        http_response_code(404);
        echo json_encode(["success" => false, "message" => "Account not found with this email address."]);
        exit();
    }

    $hash = password_hash($newPassword, PASSWORD_DEFAULT);
    $upStmt = $pdo->prepare("UPDATE users SET password_hash = ? WHERE id = ?");
    if ($upStmt->execute([$hash, $user['id']])) {
        echo json_encode(["success" => true, "message" => "Password reset successfully! You can now log in with your new password."]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to update password."]);
    }
    exit();
}

// 2. REVIEWS & RATINGS API
if ($action === 'reviews' && $method === 'GET') {
    $stmt = $pdo->query("
        SELECT r.*, u.name as user_name, u.profile_photo_url 
        FROM reviews r 
        JOIN users u ON r.user_id = u.id 
        ORDER BY r.created_at DESC
    ");
    $reviews = $stmt->fetchAll();

    $avgRating = (float)$pdo->query("SELECT COALESCE(AVG(rating), 4.9) FROM reviews")->fetchColumn();
    $totalReviews = count($reviews);

    $ratingCounts = [5 => 0, 4 => 0, 3 => 0, 2 => 0, 1 => 0];
    foreach ($reviews as $r) {
        $star = (int)$r['rating'];
        if (isset($ratingCounts[$star])) $ratingCounts[$star]++;
    }

    echo json_encode([
        "success" => true,
        "average_rating" => round($avgRating, 1),
        "total_reviews" => $totalReviews,
        "rating_counts" => $ratingCounts,
        "reviews" => $reviews
    ]);
    exit();
}

if ($action === 'add_review' && $method === 'POST') {
    $userId = (int)($data['user_id'] ?? 0);
    $destName = trim($data['destination_name'] ?? 'Paris, France');
    $rating = (int)($data['rating'] ?? 5);
    $title = trim($data['title'] ?? '');
    $comment = trim($data['comment'] ?? '');

    if ($userId <= 0 || empty($title) || empty($comment)) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Title and review comment are required."]);
        exit();
    }

    $stmt = $pdo->prepare("INSERT INTO reviews (user_id, destination_name, rating, title, comment) VALUES (?, ?, ?, ?, ?)");
    if ($stmt->execute([$userId, $destName, $rating, $title, $comment])) {
        echo json_encode(["success" => true, "message" => "Review submitted successfully!"]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to submit review."]);
    }
    exit();
}

if ($action === 'delete_review' && $method === 'DELETE') {
    $reviewId = (int)($_GET['id'] ?? 0);
    $adminUserId = (int)($_GET['user_id'] ?? 0);

    $adminCheck = $pdo->prepare("SELECT is_admin FROM users WHERE id = ?");
    $adminCheck->execute([$adminUserId]);
    $isAdmin = (int)$adminCheck->fetchColumn();

    if ($isAdmin !== 1) {
        http_response_code(403);
        echo json_encode(["success" => false, "message" => "Access denied. Only Admins can delete reviews."]);
        exit();
    }

    $stmt = $pdo->prepare("DELETE FROM reviews WHERE id = ?");
    if ($stmt->execute([$reviewId])) {
        echo json_encode(["success" => true, "message" => "Review comment deleted successfully!"]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to delete review."]);
    }
    exit();
}

// 3. USER PROFILE & SETTINGS API
if ($action === 'update_profile' && $method === 'POST') {
    $userId = (int)($data['user_id'] ?? 0);
    $name = trim($data['name'] ?? '');
    $email = trim($data['email'] ?? '');
    $photoUrl = trim($data['profile_photo_url'] ?? '');
    $language = trim($data['language_preference'] ?? 'English');

    if ($userId <= 0 || empty($name) || empty($email)) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "User ID, Name, and Email are required."]);
        exit();
    }

    $stmt = $pdo->prepare("UPDATE users SET name = ?, email = ?, profile_photo_url = ?, language_preference = ? WHERE id = ?");
    if ($stmt->execute([$name, $email, $photoUrl, $language, $userId])) {
        $uStmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
        $uStmt->execute([$userId]);
        $updatedUser = $uStmt->fetch();
        echo json_encode([
            "success" => true,
            "message" => "Profile updated successfully!",
            "user" => [
                "id" => (int)$updatedUser['id'],
                "name" => $updatedUser['name'],
                "email" => $updatedUser['email'],
                "profile_photo_url" => $updatedUser['profile_photo_url'],
                "language_preference" => $updatedUser['language_preference'],
                "is_admin" => (int)$updatedUser['is_admin']
            ]
        ]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to update profile."]);
    }
    exit();
}

if ($action === 'delete_account' && $method === 'DELETE') {
    $userId = (int)($_GET['user_id'] ?? 0);
    if ($userId <= 0) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Valid user_id is required."]);
        exit();
    }

    $stmt = $pdo->prepare("DELETE FROM users WHERE id = ?");
    if ($stmt->execute([$userId])) {
        echo json_encode(["success" => true, "message" => "Account successfully deleted."]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to delete account."]);
    }
    exit();
}

if ($action === 'saved_destinations' && $method === 'GET') {
    $userId = (int)($_GET['user_id'] ?? 0);
    $stmt = $pdo->prepare("
        SELECT d.* 
        FROM destinations d 
        JOIN user_saved_destinations s ON d.id = s.destination_id 
        WHERE s.user_id = ?
    ");
    $stmt->execute([$userId]);
    echo json_encode(["success" => true, "saved_destinations" => $stmt->fetchAll()]);
    exit();
}

if ($action === 'toggle_saved_destination' && $method === 'POST') {
    $userId = (int)($data['user_id'] ?? 0);
    $destId = (int)($data['destination_id'] ?? 0);

    $check = $pdo->prepare("SELECT id FROM user_saved_destinations WHERE user_id = ? AND destination_id = ?");
    $check->execute([$userId, $destId]);
    if ($check->fetch()) {
        $del = $pdo->prepare("DELETE FROM user_saved_destinations WHERE user_id = ? AND destination_id = ?");
        $del->execute([$userId, $destId]);
        echo json_encode(["success" => true, "message" => "Destination removed from saved list.", "is_saved" => false]);
    } else {
        $ins = $pdo->prepare("INSERT INTO user_saved_destinations (user_id, destination_id) VALUES (?, ?)");
        $ins->execute([$userId, $destId]);
        echo json_encode(["success" => true, "message" => "Destination saved!", "is_saved" => true]);
    }
    exit();
}

// 4. ADMIN ANALYTICS & USER MANAGEMENT API
if ($action === 'admin_analytics' && $method === 'GET') {
    $userId = (int)($_GET['user_id'] ?? 0);

    $adminCheck = $pdo->prepare("SELECT is_admin FROM users WHERE id = ?");
    $adminCheck->execute([$userId]);
    $isAdmin = (int)$adminCheck->fetchColumn();

    if ($isAdmin !== 1) {
        http_response_code(403);
        echo json_encode(["success" => false, "message" => "Access denied. Admin privileges required."]);
        exit();
    }

    $totalUsers = (int)$pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
    $totalTrips = (int)$pdo->query("SELECT COUNT(*) FROM trips")->fetchColumn();
    $totalBudget = (float)$pdo->query("SELECT COALESCE(SUM(budget), 0) FROM trips")->fetchColumn();
    $totalActivities = (int)$pdo->query("SELECT COUNT(*) FROM stop_activities")->fetchColumn();

    $popularCities = $pdo->query("
        SELECT *, ((visit_count * 2) + view_count) as metric_score 
        FROM destinations 
        ORDER BY metric_score DESC, visit_count DESC 
        LIMIT 6
    ")->fetchAll();

    $popularActivities = $pdo->query("
        SELECT a.*, d.name as city_name, d.country 
        FROM activities a 
        LEFT JOIN destinations d ON a.destination_id = d.id 
        ORDER BY a.popularity_score DESC 
        LIMIT 6
    ")->fetchAll();

    $usersList = $pdo->query("
        SELECT u.id, u.name, u.email, u.profile_photo_url, u.language_preference, u.is_admin, u.created_at,
        (SELECT COUNT(*) FROM trips t WHERE t.user_id = u.id) as trip_count
        FROM users u 
        ORDER BY u.created_at DESC
    ")->fetchAll();

    $categoryBreakdown = $pdo->query("
        SELECT category, COUNT(*) as count, COALESCE(SUM(cost), 0) as total_cost 
        FROM stop_activities 
        GROUP BY category 
        ORDER BY count DESC
    ")->fetchAll();

    echo json_encode([
        "success" => true,
        "kpis" => [
            "total_users" => $totalUsers,
            "total_trips" => $totalTrips,
            "total_budget" => $totalBudget,
            "total_activities" => $totalActivities
        ],
        "popular_cities" => $popularCities,
        "popular_activities" => $popularActivities,
        "user_management" => $usersList,
        "category_breakdown" => $categoryBreakdown
    ]);
    exit();
}

// 5. DASHBOARD DATA
if ($action === 'dashboard' && $method === 'GET') {
    $userId = (int)($_GET['user_id'] ?? 0);
    if ($userId <= 0) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Valid user_id is required."]);
        exit();
    }

    $stmt = $pdo->prepare("SELECT * FROM trips WHERE user_id = ? ORDER BY created_at DESC");
    $stmt->execute([$userId]);
    $trips = $stmt->fetchAll();

    $totalBudget = 0.0;
    $activeTrips = 0;
    foreach ($trips as $t) {
        $totalBudget += (float)$t['budget'];
        if ($t['status'] === 'Planned' || $t['status'] === 'Active' || $t['status'] === 'Confirmed') $activeTrips++;
    }

    $destStmt = $pdo->query("
        SELECT *, ((visit_count * 2) + view_count) as metric_score 
        FROM destinations 
        ORDER BY metric_score DESC, visit_count DESC, view_count DESC 
        LIMIT 6
    ");
    $destinations = $destStmt->fetchAll();

    echo json_encode([
        "success" => true,
        "stats" => [
            "total_trips" => count($trips),
            "active_trips" => $activeTrips,
            "total_budget" => $totalBudget
        ],
        "trips" => $trips,
        "recommended_destinations" => $destinations
    ]);
    exit();
}

// 6. TRIPS MANAGEMENT
if ($action === 'trips' && $method === 'GET') {
    $userId = (int)($_GET['user_id'] ?? 0);
    $stmt = $pdo->prepare("
        SELECT t.*, 
        (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id) as stop_count
        FROM trips t 
        WHERE t.user_id = ? 
        ORDER BY t.created_at DESC
    ");
    $stmt->execute([$userId]);
    echo json_encode(["success" => true, "trips" => $stmt->fetchAll()]);
    exit();
}

if ($action === 'create_trip' && $method === 'POST') {
    $userId = (int)($data['user_id'] ?? 0);
    $title = trim($data['title'] ?? '');
    $destination = trim($data['destination'] ?? '');
    $startDate = trim($data['start_date'] ?? '');
    $endDate = trim($data['end_date'] ?? '');
    $budget = (float)($data['budget'] ?? 0.0);
    $transportCost = (float)($data['transport_cost'] ?? 0.0);
    $hotelCost = (float)($data['hotel_cost'] ?? 0.0);
    $mealCost = (float)($data['meal_cost'] ?? 0.0);
    $travelStyle = trim($data['travel_style'] ?? 'Cultural Exploration 🏛️');
    $transportType = trim($data['transport_type'] ?? 'Flight ✈️');
    $accommodationType = trim($data['accommodation_type'] ?? 'Boutique Hotel 🏨');
    $groupSize = trim($data['group_size'] ?? 'Couple (2)');
    $currency = trim($data['currency'] ?? 'USD ($)');
    $description = trim($data['description'] ?? '');
    $coverUrl = trim($data['cover_image_url'] ?? '');
    $shareToken = 'share_' . uniqid() . '_' . rand(1000, 9999);

    $stmt = $pdo->prepare("INSERT INTO trips (user_id, title, destination, start_date, end_date, budget, transport_cost, hotel_cost, meal_cost, travel_style, transport_type, accommodation_type, group_size, currency, share_token, status, description, cover_image_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Planned', ?, ?)");
    if ($stmt->execute([$userId, $title, $destination, $startDate, $endDate, $budget, $transportCost, $hotelCost, $mealCost, $travelStyle, $transportType, $accommodationType, $groupSize, $currency, $shareToken, $description, $coverUrl])) {
        echo json_encode(["success" => true, "message" => "Trip created successfully!", "trip_id" => (int)$pdo->lastInsertId(), "share_token" => $shareToken]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to create trip."]);
    }
    exit();
}

if ($action === 'delete_trip' && $method === 'DELETE') {
    $id = (int)($_GET['id'] ?? 0);
    $stmt = $pdo->prepare("DELETE FROM trips WHERE id = ?");
    if ($stmt->execute([$id])) {
        echo json_encode(["success" => true, "message" => "Trip deleted successfully."]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to delete trip."]);
    }
    exit();
}

// 7. ITINERARY & STOPS MANAGEMENT
if ($action === 'itinerary' && $method === 'GET') {
    $tripId = (int)($_GET['trip_id'] ?? 0);
    $tripStmt = $pdo->prepare("SELECT * FROM trips WHERE id = ?");
    $tripStmt->execute([$tripId]);
    $trip = $tripStmt->fetch();

    $stopsStmt = $pdo->prepare("SELECT * FROM trip_stops WHERE trip_id = ? ORDER BY stop_order ASC, start_date ASC");
    $stopsStmt->execute([$tripId]);
    $stops = $stopsStmt->fetchAll();

    $totalActivitiesCost = 0.0;
    for ($i = 0; $i < count($stops); $i++) {
        $stopId = $stops[$i]['id'];
        $actStmt = $pdo->prepare("SELECT * FROM stop_activities WHERE stop_id = ? ORDER BY activity_order ASC, time_slot ASC");
        $actStmt->execute([$stopId]);
        $activities = $actStmt->fetchAll();

        foreach ($activities as $a) {
            $totalActivitiesCost += (float)$a['cost'];
        }
        $stops[$i]['activities'] = $activities;
    }

    echo json_encode([
        "success" => true,
        "trip" => $trip,
        "stops" => $stops,
        "total_activities_cost" => $totalActivitiesCost
    ]);
    exit();
}

if ($action === 'add_stop' && $method === 'POST') {
    $tripId = (int)($data['trip_id'] ?? 0);
    $cityName = trim($data['city_name'] ?? '');
    $country = trim($data['country'] ?? '');
    $startDate = trim($data['start_date'] ?? '');
    $endDate = trim($data['end_date'] ?? '');
    $notes = trim($data['notes'] ?? '');

    $orderStmt = $pdo->prepare("SELECT COALESCE(MAX(stop_order), 0) + 1 FROM trip_stops WHERE trip_id = ?");
    $orderStmt->execute([$tripId]);
    $nextOrder = $orderStmt->fetchColumn();

    $stmt = $pdo->prepare("INSERT INTO trip_stops (trip_id, city_name, country, stop_order, start_date, end_date, notes) VALUES (?, ?, ?, ?, ?, ?, ?)");
    if ($stmt->execute([$tripId, $cityName, $country, $nextOrder, $startDate, $endDate, $notes])) {
        $updateVisit = $pdo->prepare("UPDATE destinations SET visit_count = visit_count + 1 WHERE LOWER(name) = LOWER(?)");
        $updateVisit->execute([$cityName]);
        echo json_encode(["success" => true, "message" => "Stop added!", "stop_id" => (int)$pdo->lastInsertId()]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to add stop."]);
    }
    exit();
}

if ($action === 'delete_stop' && $method === 'DELETE') {
    $id = (int)($_GET['id'] ?? 0);
    $stmt = $pdo->prepare("DELETE FROM trip_stops WHERE id = ?");
    if ($stmt->execute([$id])) {
        echo json_encode(["success" => true, "message" => "Stop deleted."]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to delete stop."]);
    }
    exit();
}

if ($action === 'add_activity' && $method === 'POST') {
    $stopId = (int)($data['stop_id'] ?? 0);
    $title = trim($data['title'] ?? '');
    $category = trim($data['category'] ?? 'Sightseeing');
    $timeSlot = trim($data['time_slot'] ?? '09:00 AM');
    $cost = (float)($data['cost'] ?? 0.0);
    $notes = trim($data['notes'] ?? '');

    $orderStmt = $pdo->prepare("SELECT COALESCE(MAX(activity_order), 0) + 1 FROM stop_activities WHERE stop_id = ?");
    $orderStmt->execute([$stopId]);
    $nextOrder = $orderStmt->fetchColumn();

    $stmt = $pdo->prepare("INSERT INTO stop_activities (stop_id, title, category, time_slot, cost, notes, activity_order) VALUES (?, ?, ?, ?, ?, ?, ?)");
    if ($stmt->execute([$stopId, $title, $category, $timeSlot, $cost, $notes, $nextOrder])) {
        echo json_encode(["success" => true, "message" => "Activity added!", "activity_id" => (int)$pdo->lastInsertId()]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to add activity."]);
    }
    exit();
}

if ($action === 'delete_activity' && $method === 'DELETE') {
    $id = (int)($_GET['id'] ?? 0);
    $stmt = $pdo->prepare("DELETE FROM stop_activities WHERE id = ?");
    if ($stmt->execute([$id])) {
        echo json_encode(["success" => true, "message" => "Activity deleted."]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to delete activity."]);
    }
    exit();
}

if ($action === 'update_trip_expenses' && $method === 'POST') {
    $tripId = (int)($data['trip_id'] ?? 0);
    $transportCost = (float)($data['transport_cost'] ?? 0.0);
    $hotelCost = (float)($data['hotel_cost'] ?? 0.0);
    $mealCost = (float)($data['meal_cost'] ?? 0.0);
    $budget = (float)($data['budget'] ?? 0.0);

    if ($budget > 0) {
        $stmt = $pdo->prepare("UPDATE trips SET transport_cost = ?, hotel_cost = ?, meal_cost = ?, budget = ? WHERE id = ?");
        $ok = $stmt->execute([$transportCost, $hotelCost, $mealCost, $budget, $tripId]);
    } else {
        $stmt = $pdo->prepare("UPDATE trips SET transport_cost = ?, hotel_cost = ?, meal_cost = ? WHERE id = ?");
        $ok = $stmt->execute([$transportCost, $hotelCost, $mealCost, $tripId]);
    }

    if ($ok) {
        echo json_encode(["success" => true, "message" => "Expenses and customisation budget updated successfully."]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Failed to update expenses."]);
    }
    exit();
}

if ($action === 'copy_trip' && $method === 'POST') {
    $sourceTripId = (int)($data['trip_id'] ?? 0);
    $userId = (int)($data['user_id'] ?? 0);

    if ($sourceTripId <= 0 || $userId <= 0) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Invalid trip_id or user_id."]);
        exit();
    }

    $srcStmt = $pdo->prepare("SELECT * FROM trips WHERE id = ?");
    $srcStmt->execute([$sourceTripId]);
    $srcTrip = $srcStmt->fetch();

    if (!$srcTrip) {
        http_response_code(404);
        echo json_encode(["success" => false, "message" => "Source trip not found."]);
        exit();
    }

    $newTitle = 'Copy of ' . $srcTrip['title'];
    $newShareToken = 'share_' . uniqid() . '_' . rand(1000, 9999);

    $insStmt = $pdo->prepare("INSERT INTO trips (user_id, title, destination, start_date, end_date, budget, transport_cost, hotel_cost, meal_cost, travel_style, transport_type, accommodation_type, group_size, currency, share_token, status, description, cover_image_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Planned', ?, ?)");
    $insStmt->execute([
        $userId,
        $newTitle,
        $srcTrip['destination'],
        $srcTrip['start_date'],
        $srcTrip['end_date'],
        $srcTrip['budget'],
        $srcTrip['transport_cost'],
        $srcTrip['hotel_cost'],
        $srcTrip['meal_cost'],
        $srcTrip['travel_style'] ?? 'Cultural Exploration 🏛️',
        $srcTrip['transport_type'] ?? 'Flight ✈️',
        $srcTrip['accommodation_type'] ?? 'Boutique Hotel 🏨',
        $srcTrip['group_size'] ?? 'Couple (2)',
        $srcTrip['currency'] ?? 'USD ($)',
        $newShareToken,
        $srcTrip['description'],
        $srcTrip['cover_image_url']
    ]);

    $newTripId = (int)$pdo->lastInsertId();

    $stopsStmt = $pdo->prepare("SELECT * FROM trip_stops WHERE trip_id = ?");
    $stopsStmt->execute([$sourceTripId]);
    $stops = $stopsStmt->fetchAll();

    foreach ($stops as $stop) {
        $insStop = $pdo->prepare("INSERT INTO trip_stops (trip_id, city_name, country, stop_order, start_date, end_date, notes) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $insStop->execute([
            $newTripId,
            $stop['city_name'],
            $stop['country'],
            $stop['stop_order'],
            $stop['start_date'],
            $stop['end_date'],
            $stop['notes']
        ]);
        $newStopId = (int)$pdo->lastInsertId();

        $actStmt = $pdo->prepare("SELECT * FROM stop_activities WHERE stop_id = ?");
        $actStmt->execute([$stop['id']]);
        $activities = $actStmt->fetchAll();

        foreach ($activities as $act) {
            $insAct = $pdo->prepare("INSERT INTO stop_activities (stop_id, title, category, time_slot, cost, notes, activity_order) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $insAct->execute([
                $newStopId,
                $act['title'],
                $act['category'],
                $act['time_slot'],
                $act['cost'],
                $act['notes'],
                $act['activity_order']
            ]);
        }
    }

    echo json_encode([
        "success" => true,
        "message" => "Trip successfully copied to your account!",
        "new_trip_id" => $newTripId
    ]);
    exit();
}

// 8. CITY SEARCH & RECOMMENDED CITIES API
if ($action === 'cities' && $method === 'GET') {
    $query = trim($_GET['q'] ?? '');
    $region = trim($_GET['region'] ?? 'All');
    $sortBy = trim($_GET['sort'] ?? 'popular');

    $sql = "SELECT *, ((visit_count * 2) + view_count) as metric_score FROM destinations WHERE 1=1";
    $params = [];

    if (!empty($query)) {
        $sql .= " AND (name LIKE ? OR country LIKE ? OR description LIKE ?)";
        $like = "%$query%";
        $params[] = $like;
        $params[] = $like;
        $params[] = $like;
    }

    if (!empty($region) && $region !== 'All') {
        $sql .= " AND region = ?";
        $params[] = $region;
    }

    if ($sortBy === 'visits') {
        $sql .= " ORDER BY visit_count DESC, view_count DESC";
    } else if ($sortBy === 'views') {
        $sql .= " ORDER BY view_count DESC, visit_count DESC";
    } else {
        $sql .= " ORDER BY metric_score DESC, visit_count DESC, view_count DESC";
    }

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    echo json_encode(["success" => true, "cities" => $stmt->fetchAll()]);
    exit();
}

if ($action === 'record_city_view' && $method === 'POST') {
    $cityId = (int)($data['city_id'] ?? 0);
    if ($cityId > 0) {
        $stmt = $pdo->prepare("UPDATE destinations SET view_count = view_count + 1 WHERE id = ?");
        $stmt->execute([$cityId]);
        echo json_encode(["success" => true, "message" => "View recorded!"]);
    } else {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Invalid city_id."]);
    }
    exit();
}

// 9. ACTIVITY SEARCH API
if ($action === 'activities' && $method === 'GET') {
    $query = trim($_GET['q'] ?? '');
    $category = trim($_GET['category'] ?? 'All');
    $maxCost = isset($_GET['max_cost']) ? (float)$_GET['max_cost'] : 0.0;

    $sql = "SELECT a.*, d.name as city_name, d.country FROM activities a LEFT JOIN destinations d ON a.destination_id = d.id WHERE 1=1";
    $params = [];

    if (!empty($query)) {
        $sql .= " AND (a.title LIKE ? OR a.description LIKE ? OR d.name LIKE ?)";
        $like = "%$query%";
        $params[] = $like;
        $params[] = $like;
        $params[] = $like;
    }

    if (!empty($category) && $category !== 'All') {
        $sql .= " AND a.category = ?";
        $params[] = $category;
    }

    if ($maxCost > 0) {
        $sql .= " AND a.cost <= ?";
        $params[] = $maxCost;
    }

    $sql .= " ORDER BY a.popularity_score DESC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    echo json_encode(["success" => true, "activities" => $stmt->fetchAll()]);
    exit();
}

http_response_code(400);
echo json_encode(["success" => false, "message" => "Invalid API action."]);
?>
