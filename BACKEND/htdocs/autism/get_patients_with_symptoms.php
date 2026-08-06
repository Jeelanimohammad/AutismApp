<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

include 'config.php';

// Optional: Map symptom IDs to display names
function getSymptomDisplayName($symptomId) {
    $symptomsUnder3 = [
        'symptom1' => 'Not following point',
        'symptom2' => 'Not sharing on request',
        'symptom3' => 'Not imitating actions',
        'symptom4' => 'Difficulty expressing smile',
        'symptom5' => 'Poor eye contact',
        'symptom6' => 'Difficulty understanding gestures',
        'symptom7' => 'Prefers to be alone'
    ];
    
    $symptomsOver3 = [
        'sym01' => 'Prefers to be alone',
        'sym02' => 'Doesn\'t respond to sounds',
        'sym03' => 'Grabs hand to show interest',
        'sym04' => 'Overattached to objects/toys',
        'sym05' => 'Poor eye contact',
        'sym06' => 'Abnormal gestures/behaviour',
        'sym07' => 'Avoids touch or hugs',
        'sym08' => 'No imaginative play',
        'sym09' => 'Not responding to teaching',
        'sym10' => 'Shows unusual/savant skills'
    ];
    
    // Check both arrays
    if (isset($symptomsUnder3[$symptomId])) {
        return $symptomsUnder3[$symptomId];
    } else if (isset($symptomsOver3[$symptomId])) {
        return $symptomsOver3[$symptomId];
    }
    
    return $symptomId; // Return original if not found
}

$sql = "SELECT p.id, p.patient_id, p.name, p.age, p.dob, p.sex, p.phone,
        (SELECT COUNT(*) 
         FROM assessments a 
         LEFT JOIN doctor_advice da ON a.id = da.assessment_id 
         WHERE (a.patient_id = p.patient_id OR a.patient_id = CAST(p.id AS CHAR)) AND da.id IS NULL
        ) as pending_reviews
        FROM patients p 
        ORDER BY p.created_at DESC";
$result = $conn->query($sql);

$patients = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $patient_pk_id = $row['id']; // actual primary key id

        // Fetch ALL symptom responses for this patient
        $stmt = $conn->prepare("
            SELECT symptom_name, response, conclusion 
            FROM symptom_responses 
            WHERE patient_id = ? OR patient_id = ?
            ORDER BY id ASC
        ");
        $patient_id_str = (string)$row['patient_id'];
        $stmt->bind_param("ss", $patient_pk_id, $patient_id_str);
        $stmt->execute();
        $resResult = $stmt->get_result();

        $responsesArray = [];
        $yesCount = 0;
        $totalResponses = 0;

        if ($resResult && $resResult->num_rows > 0) {
            while ($r = $resResult->fetch_assoc()) {
                $symptomId = trim($r['symptom_name']);
                $response = trim($r['response']);
                
                $responsesArray[] = [
                    'symptom_name' => $symptomId,
                    'symptom_display_name' => getSymptomDisplayName($symptomId),
                    'response' => $response,
                    'conclusion' => $r['conclusion'] ?? ''
                ];

                if (strcasecmp($response, 'yes') === 0) {
                    $yesCount++;
                }
                $totalResponses++;
            }
        }
        $stmt->close();

        // Count unadvised assessments
        $p_id_str = (string)$row['patient_id'];
        $p_db_id  = (string)$row['id'];

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
            $pendingCount = ($totalResponses > 0) ? 1 : 0;
            $hasAdvice = 0;
        }

        if ($yesCount >= 1) {
            $finalResult = "Your child needs further Diagnostic Tests for Autism.";
        } else {
            $finalResult = "Your Child has no signs of Autism at present.";
        }

        $patients[] = [
            "id" => $row['id'],
            "patient_id" => $row['patient_id'],
            "name" => $row['name'],
            "age" => $row['age'],
            "dob" => $row['dob'],
            "sex" => $row['sex'],
            "phone" => $row['phone'],
            "pending_reviews" => $pendingCount,
            "reviewed_count" => $advCount,
            "has_advice" => $hasAdvice,
            "responses" => $responsesArray,
            "final_conclusion" => $finalResult,
            "yes_count" => $yesCount,
            "total_responses" => $totalResponses
        ];
    }
}

echo json_encode([
    "success" => true,
    "patients" => $patients
], JSON_PRETTY_PRINT);
$conn->close();
?>