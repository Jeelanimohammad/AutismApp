<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include 'config.php';

$sql = "SELECT id as patient_db_id, patient_id, name, age, dob, sex, phone, created_at FROM patients ORDER BY created_at DESC";
$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $patients = [];
    while ($row = $result->fetch_assoc()) {
        $patients[] = $row;
    }
    echo json_encode([
        "success" => true,
        "patients" => $patients
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "No patients found"
    ]);
}

$conn->close();
?>
