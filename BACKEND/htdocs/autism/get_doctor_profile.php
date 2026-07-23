<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

include 'config.php';

$doctor_id = isset($_GET['doctor_id']) ? $_GET['doctor_id'] : '';

if (empty($doctor_id)) {
    echo json_encode([
        "success" => false,
        "message" => "Doctor ID is required"
    ]);
    exit();
}

$sql = "SELECT * FROM doctors WHERE doctor_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $doctor_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $doctor = $result->fetch_assoc();
    // Ensure all numeric fields are converted to correct types
    $doctor['id'] = (int)$doctor['id'];
    
    echo json_encode([
        "success" => true,
        "doctor" => $doctor
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Doctor not found"
    ]);
}

$stmt->close();
$conn->close();
?>