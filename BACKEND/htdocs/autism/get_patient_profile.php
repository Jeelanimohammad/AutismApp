<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
include 'config.php';

$pid = trim($_GET['patient_id'] ?? '');

if ($pid === '') {
    echo json_encode(["success" => false, "message" => "Patient ID required"]);
    exit;
}

$stmt = $conn->prepare("SELECT id, patient_id, name, age, dob, sex, phone, email, created_at, profile_image FROM patients WHERE patient_id = ?");
$stmt->bind_param("s", $pid);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    echo json_encode([
        "success" => true,
        "data" => $row
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Patient not found"]);
}

$stmt->close();
$conn->close();
?>
