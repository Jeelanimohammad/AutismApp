<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include 'config.php';

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);

$doctor_id = trim($data['doctor_id'] ?? '');
$name = trim($data['name'] ?? '');
$email = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');
$specialization = trim($data['specialization'] ?? '');
$phone = trim($data['phone'] ?? '');

// Validate required fields
$missingFields = [];
if (empty($doctor_id)) $missingFields[] = 'doctor_id';
if (empty($name)) $missingFields[] = 'name';
if (empty($email)) $missingFields[] = 'email';
if (empty($password)) $missingFields[] = 'password';
if (empty($specialization)) $missingFields[] = 'specialization';
if (empty($phone)) $missingFields[] = 'phone';

if (!empty($missingFields)) {
    echo json_encode([
        "success" => false,
        "message" => "Missing fields: " . implode(", ", $missingFields)
    ]);
    exit;
}

// Check DB connection
if (!$conn || $conn->connect_error) {
    echo json_encode([
        "success" => false,
        "message" => "Database connection failed: " . ($conn->connect_error ?? 'unknown')
    ]);
    exit;
}

// Check if either Doctor ID OR Email already exists
$check = $conn->prepare("SELECT * FROM doctors WHERE doctor_id = ? OR email = ?");
$check->bind_param("ss", $doctor_id, $email);
$check->execute();
$result = $check->get_result();
if ($result->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Doctor ID or Email already exists"]);
    exit;
}

// ⚠️ Password stored in plain text (consider hashing)
$stmt = $conn->prepare("INSERT INTO doctors (doctor_id, name, email, password, specialization, phone) VALUES (?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssss", $doctor_id, $name, $email, $password, $specialization, $phone);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Doctor registered successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Error during registration: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
