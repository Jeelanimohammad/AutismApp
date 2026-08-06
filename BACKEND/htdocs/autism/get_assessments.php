<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
include 'config.php';

$pid = trim($_GET['patient_id'] ?? '');

if ($pid === '') {
    echo json_encode([]);
    exit;
}

$stmt = $conn->prepare("
    SELECT a.id, a.result_message, a.created_at, 
           CASE WHEN da.id IS NOT NULL THEN 1 ELSE 0 END as has_feedback
    FROM assessments a
    LEFT JOIN doctor_advice da ON a.id = da.assessment_id
    WHERE a.patient_id = ? OR a.patient_id = (SELECT CAST(id AS CHAR) FROM patients WHERE patient_id = ? LIMIT 1) OR a.patient_id = (SELECT patient_id FROM patients WHERE CAST(id AS CHAR) = ? LIMIT 1)
    GROUP BY a.id
    ORDER BY a.created_at DESC
");
$stmt->bind_param("sss", $pid, $pid, $pid);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);

$stmt->close();
$conn->close();
?>
