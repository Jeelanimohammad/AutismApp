<?php
error_reporting(0);
ini_set('display_errors', 0);
ob_start();

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include 'config.php'; 

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);

$response = ["success" => false, "message" => "Unknown error"];

$email = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');

if (empty($email) || empty($password)) {
    $response["message"] = "Email and password required";
    ob_end_clean();
    echo json_encode($response);
    exit;
}

// Check DB connection
if (!$conn || $conn->connect_error) {
    $response["message"] = "Database connection failed";
    ob_end_clean();
    echo json_encode($response);
    exit;
}

// Use prepared statement
$stmt = $conn->prepare("SELECT doctor_id, name, email, specialization, phone, password FROM doctors WHERE email = ?");
if (!$stmt) {
    $response["message"] = "Query preparation failed: " . $conn->error;
    ob_end_clean();
    echo json_encode($response);
    exit;
}

$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
    $doctor = $result->fetch_assoc();

    if ($password === $doctor['password']) {
        unset($doctor['password']); // remove password
        $response = [
            "success" => true,
            "message" => "Login successful",
            "doctor"  => $doctor
        ];
    } else {
        $response["message"] = "Invalid email or password";
    }
} else {
    $response["message"] = "Invalid email or password";
}

$stmt->close();
$conn->close();

// FINAL CLEANUP
ob_end_clean();
echo json_encode($response);
?>
