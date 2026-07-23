<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
include 'config.php';

$pid = trim($_GET['patient_id'] ?? '');
if ($pid==='') { echo json_encode([]); exit; }

$assessment_id = isset($_GET['assessment_id']) ? intval($_GET['assessment_id']) : null;

if ($assessment_id) {
    $stmt = $conn->prepare("SELECT id, doctor_name, advice_text, created_at FROM doctor_advice WHERE patient_id = ? AND assessment_id = ? ORDER BY created_at DESC");
    $stmt->bind_param("si", $pid, $assessment_id);
} else {
    $stmt = $conn->prepare("SELECT id, doctor_name, advice_text, created_at FROM doctor_advice WHERE patient_id = ? ORDER BY created_at DESC");
    $stmt->bind_param("s", $pid);
}
$stmt->execute();
$res = $stmt->get_result();

$data=[];
while($row=$res->fetch_assoc()){
    $data[]=$row;
}

echo json_encode($data);
?>
