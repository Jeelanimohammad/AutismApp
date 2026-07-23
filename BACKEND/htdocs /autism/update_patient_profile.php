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

$patient_id = $data['patient_id'] ?? '';
$name = $data['name'] ?? '';
$age = $data['age'] ?? '';
$dob = $data['dob'] ?? '';
$sex = $data['sex'] ?? '';
$phone = $data['phone'] ?? '';
$email = $data['email'] ?? '';
$profile_image = $data['profile_image'] ?? ''; // This could be a base64 string or a URL

if (!$patient_id) {
    echo json_encode(["success" => false, "message" => "Patient ID missing"]);
    exit;
}

// Convert dob if needed
// Standardize DOB format to YYYY-MM-DD
if (strpos($dob, '/') !== false) {
    $parts = explode('/', $dob);
    if (count($parts) === 3) {
        $dob = $parts[2] . '-' . $parts[1] . '-' . $parts[0];
    }
}

if ($profile_image && strpos($profile_image, 'data:image') !== false) {
    // Handle base64 image upload
    $parts = explode(',', $profile_image);
    $image_data = base64_decode(end($parts));
    $filename = 'profile_' . $patient_id . '_' . time() . '.png';
    $path = 'uploads/' . $filename;
    
    if (!file_exists('uploads')) {
        mkdir('uploads', 0777, true);
    }
    
    $saved_image_path = "";
    if (file_put_contents($path, $image_data)) {
        $saved_image_path = $path; // Save relative path
        
        $sql = "UPDATE patients SET name=?, age=?, dob=?, sex=?, phone=?, email=?, profile_image=? WHERE patient_id=?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("sissssss", $name, $age, $dob, $sex, $phone, $email, $saved_image_path, $patient_id);
    } else {
        // Fallback if upload fails
        $sql = "UPDATE patients SET name=?, age=?, dob=?, sex=?, phone=?, email=? WHERE patient_id=?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("sisssss", $name, $age, $dob, $sex, $phone, $email, $patient_id);
    }
} else if ($profile_image === "") {
    // Explicitly remove the profile image
    $sql = "UPDATE patients SET name=?, age=?, dob=?, sex=?, phone=?, email=?, profile_image=NULL WHERE patient_id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sisssss", $name, $age, $dob, $sex, $phone, $email, $patient_id);
} else {
    // Keep existing image if profile_image is not provided or is just a URL string we already have
    $sql = "UPDATE patients SET name=?, age=?, dob=?, sex=?, phone=?, email=? WHERE patient_id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sisssss", $name, $age, $dob, $sex, $phone, $email, $patient_id);
}

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Profile updated successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Error update: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>
