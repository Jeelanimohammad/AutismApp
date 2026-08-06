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

if ($data === null) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid JSON received. Raw: " . $raw . " Error: " . json_last_error_msg()
    ]);
    exit;
}

if (empty($data['patient_id'])) {
    echo json_encode([
        "success" => false,
        "message" => "Patient ID is missing. Raw: " . $raw
    ]);
    exit;
}

/* READ FIELDS */
$patient_id  = $data['patient_id'];
$doctor_name = $data['doctor_name'] ?? '';
$advice_text = $data['advice_text'] ?? '';

$assessment_id = $data['assessment_id'] ?? null;

/* INSERT */
$stmt = $conn->prepare(
    "INSERT INTO doctor_advice (patient_id, doctor_name, advice_text, assessment_id)
     VALUES (?, ?, ?, ?)"
);

if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "Prepare failed: " . $conn->error
    ]);
    exit;
}

$stmt->bind_param("sssi", $patient_id, $doctor_name, $advice_text, $assessment_id);

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
