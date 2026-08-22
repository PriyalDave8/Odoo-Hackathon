<?php
$ch = curl_init('http://127.0.0.1:8088/api.php?action=login');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(['email'=>'alex@globetrotter.com', 'password'=>'password123']));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type:application/json']);
$response = curl_exec($ch);
echo "API Login Test Output: " . $response . "\n";
?>
