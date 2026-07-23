<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Only POST method is allowed"]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);
$patient_id = $data['patient_id'] ?? '';
$responses = $data['responses'] ?? [];

if (empty($patient_id) || empty($responses)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "patient_id and responses are required"]);
    exit;
}

// Get DB internal ID for patient
$db_id = null;
$v_stmt = $conn->prepare("SELECT id FROM patients WHERE patient_id = ?");
$v_stmt->bind_param("s", $patient_id);
$v_stmt->execute();
if ($row = $v_stmt->get_result()->fetch_assoc()) {
    $db_id = $row['id'];
}
$v_stmt->close();

if (!$db_id) {
    http_response_code(404);
    echo json_encode(["success" => false, "message" => "Patient not found"]);
    exit;
}

// Calculate conclusion
$hasYes = false;
foreach ($responses as $resp) {
    if (strtolower($resp['response'] ?? '') === 'yes') {
        $hasYes = true;
        break;
    }
}
$result_msg = $hasYes ? "Your child needs further Diagnostic Tests for Autism." : "Your Child has no signs of Autism at present";

$conn->begin_transaction();
try {
    // 1. Create Assessment
    $stmt_a = $conn->prepare("INSERT INTO assessments (patient_id, result_message, created_at) VALUES (?, ?, NOW())");
    $stmt_a->bind_param("ss", $patient_id, $result_msg);
    $stmt_a->execute();
    $assessment_id = $stmt_a->insert_id;
    $stmt_a->close();

    // 2. Save Symptom Responses
    foreach ($responses as $resp) {
        $sname = $resp['symptom_name'] ?? '';
        $rtext = $resp['response'] ?? '';
        $conc = $resp['conclusion'] ?? '';

        $stmt_s = $conn->prepare("INSERT INTO symptom_responses (patient_id, assessment_id, symptom_name, response, conclusion, created_at) VALUES (?, ?, ?, ?, ?, NOW())");
        $stmt_s->bind_param("iisss", $db_id, $assessment_id, $sname, $rtext, $conc);
        $stmt_s->execute();
        $stmt_s->close();
    }

    $conn->commit();
    echo json_encode([
        "success" => true, 
        "message" => "Assessment saved", 
        "result_message" => $result_msg,
        "assessment_id" => $assessment_id
    ]);
} catch (Exception $e) {
    $conn->rollback();
    http_response_code(500);
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
$conn->close();
?>
