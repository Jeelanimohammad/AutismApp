<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include 'config.php';

$sql = "
    SELECT 
        p.id as patient_db_id, 
        p.patient_id, 
        p.name, 
        p.age, 
        p.dob, 
        p.sex, 
        p.phone, 
        p.created_at,
        (SELECT COUNT(*) 
         FROM assessments a 
         LEFT JOIN doctor_advice da ON a.id = da.assessment_id 
         WHERE a.patient_id = p.patient_id AND da.id IS NULL
        ) as pending_reviews
    FROM patients p 
    ORDER BY p.created_at DESC";
$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $patients = [];
    while ($row = $result->fetch_assoc()) {
        $p_id_str = (string)$row['patient_id'];
        $p_db_id  = (string)$row['patient_db_id'];

        $asmStmt = $conn->prepare("
            SELECT COUNT(*) as unadvised_cnt 
            FROM assessments a 
            LEFT JOIN doctor_advice da ON a.id = da.assessment_id 
            WHERE (a.patient_id = ? OR a.patient_id = ?) AND da.id IS NULL
        ");
        $asmStmt->bind_param("ss", $p_id_str, $p_db_id);
        $asmStmt->execute();
        $asmRes = $asmStmt->get_result()->fetch_assoc();
        $unadvisedCount = (int)($asmRes['unadvised_cnt'] ?? 0);
        $asmStmt->close();

        $advStmt = $conn->prepare("SELECT COUNT(*) as adv_cnt FROM doctor_advice WHERE patient_id = ? OR patient_id = ?");
        $advStmt->bind_param("ss", $p_id_str, $p_db_id);
        $advStmt->execute();
        $advRes = $advStmt->get_result()->fetch_assoc();
        $advCount = (int)($advRes['adv_cnt'] ?? 0);
        $advStmt->close();

        if ($unadvisedCount > 0) {
            $pendingCount = $unadvisedCount;
            $hasAdvice = 0; // Patient is NOT fully reviewed until ALL reports have been advised!
        } else if ($advCount > 0) {
            $pendingCount = 0;
            $hasAdvice = 1; // Fully reviewed!
        } else {
            $pendingCount = 0;
            $hasAdvice = 0;
        }

        $row['pending_reviews'] = $pendingCount;
        $row['reviewed_count']  = $advCount;
        $row['has_advice']      = $hasAdvice;
        $patients[] = $row;
    }
    echo json_encode([
        "success" => true,
        "patients" => $patients
    ]);
} else {
    echo json_encode([
        "success" => true,
        "patients" => []
    ]);
}

$conn->close();
?>
