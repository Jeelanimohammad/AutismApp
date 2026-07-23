<?php
header("Content-Type: application/json");
include 'config.php';

$stmt = $conn->prepare("SELECT patient_id, name, profile_image FROM patients");
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode(["success" => true, "data" => $data]);
$stmt->close();
$conn->close();
?>
