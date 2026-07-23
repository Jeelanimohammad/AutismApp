<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
include 'config.php';

$aid = intval($_GET['assessment_id'] ?? 0);

if ($aid === 0) {
    echo json_encode(["success" => false, "message" => "assessment_id required"]);
    exit;
}

// Get basic assessment info
$stmt = $conn->prepare("SELECT result_message, created_at FROM assessments WHERE id = ?");
$stmt->bind_param("i", $aid);
$stmt->execute();
$info = $stmt->get_result()->fetch_assoc();
$stmt->close();

if (!$info) {
    echo json_encode(["success" => false, "message" => "Assessment not found"]);
    exit;
}

// Get detailed responses
// We don't have displaying names in symptom_responses, so we join with symptoms if possible
// Or just return the names stored
$stmt = $conn->prepare("SELECT symptom_name, response, conclusion FROM symptom_responses WHERE assessment_id = ?");
$stmt->bind_param("i", $aid);
$stmt->execute();
$res = $stmt->get_result();

$responses = [];
while ($row = $res->fetch_assoc()) {
    $responses[] = $row;
}
$stmt->close();

echo json_encode([
    "success" => true,
    "result_message" => $info['result_message'],
    "created_at" => $info['created_at'],
    "responses" => $responses
]);

$conn->close();
?>
