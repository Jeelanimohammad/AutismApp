<?php
header("Content-Type: application/json");
ini_set('display_errors', 1);
error_reporting(E_ALL);

include 'config.php';

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);
$email = $data['email'] ?? '';

if (empty($email)) {
    echo json_encode(["success" => false, "message" => "Email required"]);
    exit;
}

$email = $conn->real_escape_string($email);

// ✅ Use the correct table name: doctors
$sql = "SELECT doctor_id, name, email, specialization, phone 
        FROM doctors 
        WHERE email = '$email'";

$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $doctor = $result->fetch_assoc();
    echo json_encode([
        "success" => true,
        "doctor" => $doctor
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Doctor not found"]);
}

$conn->close();
?>
