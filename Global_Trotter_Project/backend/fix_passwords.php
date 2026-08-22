<?php
require_once 'config.php';

$hash = password_hash('password123', PASSWORD_BCRYPT);
$stmt = $pdo->prepare("UPDATE users SET password_hash = ?");
if ($stmt->execute([$hash])) {
    echo "All user passwords successfully reset to 'password123'!\n";
} else {
    echo "Failed to update passwords.\n";
}
?>
