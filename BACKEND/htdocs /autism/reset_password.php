<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include 'config.php';

$inputJSON = file_get_contents('php://input');
$data = json_decode($inputJSON, true);

if (!$data) {
    echo json_encode(["success" => false, "message" => "No data provided"]);
    exit;
}

$email = trim($data['email'] ?? '');
$new_password = trim($data['password'] ?? '');

if (empty($email) || empty($new_password)) {
    echo json_encode(["success" => false, "message" => "Email and new password are required"]);
    exit;
}

// 1. Check if it's a patient (parent)
$stmt = $conn->prepare("SELECT patient_id FROM patients WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $stmt = $conn->prepare("UPDATE patients SET password = ? WHERE email = ?");
    $stmt->bind_param("ss", $new_password, $email);
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Patient password updated successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error updating patient password"]);
    }
    $stmt->close();
    $conn->close();
    exit;
}

// 2. Check if it's a doctor
$stmt = $conn->prepare("SELECT doctor_id FROM doctors WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $stmt = $conn->prepare("UPDATE doctors SET password = ? WHERE email = ?");
    $stmt->bind_param("ss", $new_password, $email);
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Doctor password updated successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error updating doctor password"]);
    }
    $stmt->close();
    $conn->close();
    exit;
}

echo json_encode(["success" => false, "message" => "No account found with this email"]);
$conn->close();
?>
