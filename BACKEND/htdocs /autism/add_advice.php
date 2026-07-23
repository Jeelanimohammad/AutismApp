<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include "config.php";

/* READ RAW JSON */
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

/* DEBUG: LOG INPUT */
file_put_contents("advice_debug.txt", $raw . PHP_EOL, FILE_APPEND);

/* READ FIELDS */
$patient_id  = $data['patient_id']  ?? '';
$doctor_name = $data['doctor_name'] ?? '';
$doctor_id   = $data['doctor_id']   ?? '';
$advice_text = $data['advice_text'] ?? '';

$assessment_id = $data['assessment_id'] ?? null;

/* INSERT */
$stmt = $conn->prepare(
    "INSERT INTO doctor_advice (patient_id, doctor_name, doctor_id, advice_text, assessment_id)
     VALUES (?, ?, ?, ?, ?)"
);

if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "Prepare failed: " . $conn->error
    ]);
    exit;
}

$stmt->bind_param("ssssi", $patient_id, $doctor_name, $doctor_id, $advice_text, $assessment_id);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Advice saved successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "DB Insert failed: " . $stmt->error
    ]);
}


$stmt->close();
$conn->close();
