<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'config.php';

// Get POST data
$data = json_decode(file_get_contents("php://input"), true);

$doctor_id = isset($data['doctor_id']) ? trim($data['doctor_id']) : '';
$name = isset($data['name']) ? trim($data['name']) : '';
$email = isset($data['email']) ? trim($data['email']) : '';
$phone = isset($data['phone']) ? trim($data['phone']) : '';
$specialization = isset($data['specialization']) ? trim($data['specialization']) : '';
$profile_image_base64 = isset($data['profile_image']) ? $data['profile_image'] : '';

// Validate required fields
if (empty($doctor_id) || empty($name) || empty($email) || empty($phone) || empty($specialization)) {
    echo json_encode([
        "success" => false,
        "message" => "All fields are required"
    ]);
    exit();
}

// Handle profile image if provided
$profile_image_url = null;
$image_action = 'keep'; // 'keep' | 'update' | 'remove'

if (!empty($profile_image_base64)) {
    if (preg_match('/^data:image\/(\w+);base64,/', $profile_image_base64, $type)) {
        $profile_image_base64 = substr($profile_image_base64, strpos($profile_image_base64, ',') + 1);
        $type = strtolower($type[1]); // jpg, png, gif

        if (!in_array($type, ['jpg', 'jpeg', 'gif', 'png'])) {
            echo json_encode(["success" => false, "message" => "Invalid image type"]);
            exit();
        }

        $profile_image_base64 = base64_decode($profile_image_base64);

        if ($profile_image_base64 === false) {
            echo json_encode(["success" => false, "message" => "Base64 decode failed"]);
            exit();
        }

        $file_name = "doc_" . $doctor_id . "_" . time() . "." . $type;
        $upload_path = "uploads/" . $file_name;
        
        if (!is_dir('uploads')) {
            mkdir('uploads', 0777, true);
        }

        if (file_put_contents($upload_path, $profile_image_base64)) {
            $server_host = $_SERVER['HTTP_HOST'] ?? 'localhost';
            $profile_image_url = "http://" . $server_host . "/autism/" . $upload_path;
            $image_action = 'update';
        }
    } else {
        $image_action = 'keep';
    }
} else {
    $image_action = 'remove';
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid email format"
    ]);
    exit();
}

// Validate phone number (10 digits)
if (!preg_match("/^[0-9]{10}$/", $phone)) {
    echo json_encode([
        "success" => false,
        "message" => "Phone number must be 10 digits"
    ]);
    exit();
}

// Update doctor profile
if ($image_action === 'update') {
    $sql = "UPDATE doctors SET name = ?, email = ?, phone = ?, specialization = ?, profile_image = ? WHERE doctor_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssssss", $name, $email, $phone, $specialization, $profile_image_url, $doctor_id);
} elseif ($image_action === 'remove') {
    $sql = "UPDATE doctors SET name = ?, email = ?, phone = ?, specialization = ?, profile_image = NULL WHERE doctor_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssss", $name, $email, $phone, $specialization, $doctor_id);
} else {
    $sql = "UPDATE doctors SET name = ?, email = ?, phone = ?, specialization = ? WHERE doctor_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssss", $name, $email, $phone, $specialization, $doctor_id);
}

if ($stmt->execute()) {
    // success even if affected_rows is 0 (no changes made)
    echo json_encode([
        "success" => true,
        "message" => "Profile updated successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to update profile: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>