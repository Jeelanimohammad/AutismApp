<?php
error_reporting(0);
ini_set('display_errors', 0);
ob_start();

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include 'config.php';

// Read raw input
$inputJSON = file_get_contents('php://input');
$data = json_decode($inputJSON, true);

// Fallback to $_POST if JSON is empty
if (!$data && isset($_POST)) {
    $data = $_POST;
}

$response = ["success" => false, "message" => "Unknown error"];

// Validate JSON decoding
if ($data === null && json_last_error() !== JSON_ERROR_NONE) {
    $response["message"] = "Error decoding JSON: " . json_last_error_msg();
    ob_end_clean();
    echo json_encode($response);
    exit;
}

// Extract fields
$patient_id = trim($data['patient_id'] ?? '');
$password = trim($data['password'] ?? '');

// Validate required fields
if (empty($patient_id) || empty($password)) {
    $response["message"] = "Patient ID and password are required";
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

// Fetch patient record
$stmt = $conn->prepare("SELECT id, patient_id, name, age, password, profile_image FROM patients WHERE patient_id = ? LIMIT 1");
if (!$stmt) {
    $response["message"] = "Error preparing statement: " . $conn->error;
    ob_end_clean();
    echo json_encode($response);
    exit;
}

$stmt->bind_param("s", $patient_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();

    if ($password === $row['password']) {
        $response = [
            "success" => true,
            "patient_db_id" => (int)$row['id'],
            "patient_id" => $row['patient_id'],
            "name" => $row['name'],
            "age" => (int)$row['age'],
            "profile_image" => $row['profile_image']
        ];
    } else {
        $response["message"] = "Invalid password";
    }
} else {
    $response["message"] = "Patient not found";
}

$stmt->close();
$conn->close();

// FINAL CLEANUP: Discard any stray characters and send clean JSON
ob_end_clean();
echo json_encode($response);
?>