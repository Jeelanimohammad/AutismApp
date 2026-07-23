<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
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
$name = trim($data['name'] ?? '');
$age = trim($data['age'] ?? '');
$dob = trim($data['dob'] ?? '');
$sex = trim($data['sex'] ?? '');
$phone = trim($data['phone'] ?? '');
$email = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');

// Validate fields
$missingFields = [];
if (empty($patient_id)) $missingFields[] = 'patient_id';
if (empty($name)) $missingFields[] = 'name';
if (empty($age)) $missingFields[] = 'age';
if (empty($dob)) $missingFields[] = 'dob';
if (empty($sex)) $missingFields[] = 'sex';
if (empty($phone)) $missingFields[] = 'phone';
if (empty($password)) $missingFields[] = 'password';

if (!empty($missingFields)) {
    $response["message"] = "Missing fields: " . implode(", ", $missingFields);
    if (ob_get_length()) ob_end_clean();
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

// Check for duplicate Patient ID
$checkID = $conn->prepare("SELECT id FROM patients WHERE patient_id = ?");
$checkID->bind_param("s", $patient_id);
$checkID->execute();
$resultID = $checkID->get_result();
if ($resultID->num_rows > 0) {
    $response["message"] = "Patient ID already exists";
    $checkID->close();
    ob_end_clean();
    echo json_encode($response);
    exit;
}
$checkID->close();

// Check for duplicate Phone
$checkPhone = $conn->prepare("SELECT id FROM patients WHERE phone = ?");
$checkPhone->bind_param("s", $phone);
$checkPhone->execute();
$resultPhone = $checkPhone->get_result();
if ($resultPhone->num_rows > 0) {
    $response["message"] = "Phone number already registered";
    $checkPhone->close();
    ob_end_clean();
    echo json_encode($response);
    exit;
}
$checkPhone->close();

// Convert DOB format from DD/MM/YYYY to YYYY-MM-DD
$dobParts = explode('/', $dob);
$dob_mysql = count($dobParts) === 3 ? $dobParts[2] . '-' . $dobParts[1] . '-' . $dobParts[0] : $dob;

// Insert into DB
$stmt = $conn->prepare("INSERT INTO patients (patient_id, name, age, dob, sex, phone, email, password, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())");
if ($stmt) {
    $stmt->bind_param("ssisssss", $patient_id, $name, $age, $dob_mysql, $sex, $phone, $email, $password);
    if ($stmt->execute()) {
        $response = [
            "success" => true,
            "message" => "Patient registered successfully",
            "patient_db_id" => (int)$conn->insert_id
        ];
    } else {
        $response["message"] = "Database error: " . $stmt->error;
    }
    $stmt->close();
} else {
    $response["message"] = "Error preparing statement: " . $conn->error;
}

$conn->close();

// FINAL CLEANUP: Discard any stray characters and send clean JSON
if (ob_get_length()) ob_end_clean();
echo json_encode($response);
?>
