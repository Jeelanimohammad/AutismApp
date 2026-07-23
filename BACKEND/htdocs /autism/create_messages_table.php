<?php
include 'config.php';

$sql = "CREATE TABLE IF NOT EXISTS messages (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    sender_id VARCHAR(50) NOT NULL,
    receiver_id VARCHAR(50) NOT NULL,
    sender_role ENUM('doctor', 'patient') NOT NULL,
    message_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Messages table created successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Error creating table: " . $conn->error]);
}

$conn->close();
?>
