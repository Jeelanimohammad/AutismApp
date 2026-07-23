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
        // Convert count to integer
        $row['pending_reviews'] = (int)$row['pending_reviews'];
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
