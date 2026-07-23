<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

include 'config.php'; // your DB connection

// Get POST data
$input = json_decode(file_get_contents('php://input'), true);

$patient_id = isset($input['patient_id']) ? trim($input['patient_id']) : '';
$advice_text = isset($input['advice_text']) ? trim($input['advice_text']) : '';

// Validate input
if (empty($patient_id) || empty($advice_text)) {
    echo json_encode(['success' => false, 'message' => 'Patient ID and advice text are required']);
    exit;
}

// Insert into doctor_advice table
$stmt = $conn->prepare("INSERT INTO doctor_advice (patient_id, advice_text) VALUES (?, ?)");
$stmt->bind_param("ss", $patient_id, $advice_text);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Advice sent successfully']);
} else {
    echo json_encode(['success' => false, 'message' => 'Failed to send advice']);
}
?>
