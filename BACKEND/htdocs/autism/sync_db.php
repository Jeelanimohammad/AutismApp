<?php
header("Content-Type: application/json");
include 'config.php';

$queries = [
    // Create doctor_advice table if it doesn't exist
    "CREATE TABLE IF NOT EXISTS `doctor_advice` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `assessment_id` int(11) DEFAULT NULL,
        `patient_id` varchar(50) DEFAULT NULL,
        `doctor_name` varchar(100) DEFAULT NULL,
        `advice_text` text DEFAULT NULL,
        `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;",

    // Create assessments table if it doesn't exist
    "CREATE TABLE IF NOT EXISTS `assessments` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `patient_id` varchar(50) DEFAULT NULL,
        `result_message` text DEFAULT NULL,
        `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;",

    // Ensure doctor_advice has assessment_id
    "ALTER TABLE `doctor_advice` ADD COLUMN IF NOT EXISTS `assessment_id` INT DEFAULT NULL AFTER `id`;",

    // Ensure patients has email column
    "ALTER TABLE `patients` ADD COLUMN IF NOT EXISTS `email` varchar(100) DEFAULT NULL AFTER `phone`;",

    // Ensure patients has password column
    "ALTER TABLE `patients` ADD COLUMN IF NOT EXISTS `password` varchar(255) NOT NULL DEFAULT '';"
];

$results = [];
foreach ($queries as $sql) {
    if ($conn->query($sql)) {
        $results[] = ["query" => $sql, "success" => true];
    } else {
        $results[] = ["query" => $sql, "success" => false, "error" => $conn->error];
    }
}

echo json_encode([
    "success" => true,
    "message" => "Database schema verified/updated",
    "details" => $results
]);

$conn->close();
?>
