<?php
// get_advice.php
header('Content-Type: application/json');
include 'db_connection.php'; // your DB connection

$patient_id = isset($_GET['patient_id']) ? $_GET['patient_id'] : '';

if(!$patient_id) {
    echo json_encode([]);
    exit;
}

$sql = "SELECT advice_text, timestamp FROM doctor_advice WHERE patient_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $patient_id);
$stmt->execute();
$result = $stmt->get_result();

$advice = [];
while($row = $result->fetch_assoc()) {
    $advice[] = [
        "advice_text" => $row['advice_text'],
        "timestamp" => $row['timestamp']
    ];
}

echo json_encode($advice);
$conn->close();
?>
