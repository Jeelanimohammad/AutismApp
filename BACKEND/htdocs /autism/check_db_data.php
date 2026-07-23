<?php
header("Content-Type: application/json");
include 'config.php';

$sql = "SELECT id, patient_id, name, age, dob, sex, phone, email, created_at FROM patients ORDER BY created_at DESC LIMIT 5";
$result = $conn->query($sql);

$patients = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $patients[] = $row;
    }
}

echo json_encode([
    "success" => true, 
    "db_name" => $db,
    "patient_count" => count($patients),
    "recent_patients" => $patients,
    "error" => $conn->error
]);

$conn->close();
?>
