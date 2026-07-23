<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
include 'config.php';

// Diagnostic: Check every possible input source
$input = json_decode(file_get_contents("php://input"), true);
$headers = getallheaders();

// Priority: Header > Body > POST > GET > REQUEST
$patient_id = '';
if (isset($headers['X-Patient-ID'])) {
    $patient_id = $headers['X-Patient-ID'];
} elseif (isset($headers['x-patient-id'])) {
     $patient_id = $headers['x-patient-id'];
} elseif (isset($input['patient_id'])) {
    $patient_id = $input['patient_id'];
} elseif (isset($_POST['patient_id'])) {
    $patient_id = $_POST['patient_id'];
} elseif (isset($_GET['patient_id'])) {
    $patient_id = $_GET['patient_id'];
}

$patient_id = trim($patient_id);

if (!$patient_id) {
    echo json_encode([
        "success" => false, 
        "message" => "ERROR: ID_MISSING_AT_" . __FILE__, // THIS WILL TELL US THE FOLDER
        "diagnostic" => "Headers: " . json_encode($headers) . " Body: " . file_get_contents("php://input")
    ]);
    exit;
}

try {
    $conn->query("SET FOREIGN_KEY_CHECKS = 0");
    $p_id_esc = $conn->real_escape_string($patient_id);
    
    // Nuclear Purge
    $conn->query("DELETE FROM doctor_advice WHERE patient_id = '$p_id_esc'");
    $conn->query("DELETE FROM assessments WHERE patient_id = '$p_id_esc'");
    $conn->query("DELETE FROM symptom_responses WHERE patient_id = '$p_id_esc'");
    
    $find = $conn->query("SELECT id FROM patients WHERE patient_id = '$p_id_esc'");
    if ($find && $prow = $find->fetch_assoc()) {
        $db_id = $prow['id'];
        $conn->query("DELETE FROM doctor_advice WHERE patient_id = $db_id");
        $conn->query("DELETE FROM assessments WHERE patient_id = $db_id");
        $conn->query("DELETE FROM symptom_responses WHERE patient_id = $db_id");
        $conn->query("DELETE FROM patients WHERE id = $db_id");
    }
    $conn->query("DELETE FROM patients WHERE patient_id = '$p_id_esc'");
    
    $conn->query("SET FOREIGN_KEY_CHECKS = 1");

    echo json_encode(["success" => true, "message" => "DELETED_SUCCESFULLY_" . $patient_id]);
} catch (Exception $e) {
    $conn->query("SET FOREIGN_KEY_CHECKS = 1");
    echo json_encode(["success" => false, "message" => "DB_ERR: " . $e->getMessage()]);
}

$conn->close();
?>
