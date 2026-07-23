<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
include 'config.php';

$input = json_decode(file_get_contents("php://input"), true);
$assessment_id = intval($input['assessment_id'] ?? ($_POST['assessment_id'] ?? 0));

if ($assessment_id === 0) {
    echo json_encode(["success" => false, "message" => "Assessment ID missing"]);
    exit;
}

try {
    // 1. Delete associated doctor feedback first
    $conn->query("DELETE FROM doctor_advice WHERE assessment_id = $assessment_id");

    // 2. Delete associated symptom responses
    $conn->query("DELETE FROM symptom_responses WHERE assessment_id = $assessment_id");

    // 3. Delete the assessment itself
    $stmt = $conn->prepare("DELETE FROM assessments WHERE id = ?");
    $stmt->bind_param("i", $assessment_id);
    $stmt->execute();
    
    if ($stmt->affected_rows > 0) {
        echo json_encode(["success" => true, "message" => "Report permanently deleted from database"]);
    } else {
        echo json_encode(["success" => false, "message" => "Report not found or already removed"]);
    }
    $stmt->close();

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Database Error: " . $e->getMessage()]);
}

$conn->close();
?>
