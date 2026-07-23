<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include 'config.php'; 

// Enable error logging for debugging
error_reporting(E_ALL);
ini_set('display_errors', 0); // Don't display errors in response
ini_set('log_errors', 1);
error_log("=== New Request ===");

$data = json_decode(file_get_contents("php://input"), true);

// Log the incoming request
error_log("Received data: " . print_r($data, true));

$age = intval($data['age'] ?? 0);
$patient_id = $data['patient_id'] ?? '';

if ($age <= 0) {
    echo json_encode(["success" => false, "message" => "Age is required"]);
    error_log("Error: Age is required or invalid");
    exit;
}

// FIXED: Determine age group correctly
// Age < 3 = '<3'
// Age >= 3 = '>3'
$age_group = ($age < 3) ? '<3' : '>3';

error_log("Patient Age: $age, Determined Age Group: $age_group");

// Use prepared statement to prevent SQL injection and handle special characters
$sql = "SELECT id, symptom_name, explanation, age_group, image_url 
        FROM symptoms 
        WHERE age_group = ? 
        ORDER BY id ASC";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    error_log("SQL Prepare Error: " . $conn->error);
    echo json_encode([
        "success" => false, 
        "message" => "Database query preparation failed"
    ]);
    exit;
}

$stmt->bind_param("s", $age_group);
$stmt->execute();
$result = $stmt->get_result();

error_log("Query returned " . $result->num_rows . " rows for age group: $age_group");

if ($result && $result->num_rows > 0) {
    $symptoms = [];
    while ($row = $result->fetch_assoc()) {
        error_log("Fetched symptom: " . $row['symptom_name'] . " (Age Group: " . $row['age_group'] . ")");
        
        // Clean and validate each field
        $row['id'] = (int)$row['id'];
        $row['symptom_name'] = trim($row['symptom_name']);
        $row['age_group'] = trim($row['age_group']);
        
        // Clean explanation - remove extra whitespace and newlines
        if (isset($row['explanation'])) {
            $row['explanation'] = trim(preg_replace('/\s+/', ' ', $row['explanation']));
        } else {
            $row['explanation'] = '';
        }
        
        // Fix image URL - handle both relative and absolute paths
        if (!empty($row['image_url'])) {
            $img = trim($row['image_url']);
            
            // If the image path contains 'images/' but the images folder doesn't exist, 
            // check if there's a corresponding image in 'uploads/'
            if (strpos($img, 'images/') !== false && !is_dir('images')) {
                // If the file is missing, we still try to return the full URL 
                // but we might want to check the uploads folder later.
            }

            if (!preg_match("~^https?://~i", $img)) {
                $protocol = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? "https" : "http";
                $host = $_SERVER['HTTP_HOST'];
                $currentPath = dirname($_SERVER['PHP_SELF']);
                $img = "$protocol://$host$currentPath/" . ltrim($img, '/');
            }
            $row['image_url'] = $img;
        } else {
            // Default placeholder
            $protocol = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? "https" : "http";
            $host = $_SERVER['HTTP_HOST'];
            $currentPath = dirname($_SERVER['PHP_SELF']);
            $row['image_url'] = "$protocol://$host$currentPath/uploads/image_1.png";
        }

        $symptoms[] = $row;
    }

    error_log("Returning " . count($symptoms) . " symptoms");
    
    echo json_encode([
        "success" => true,
        "data" => $symptoms,
        "age_group" => $age_group,
        "count" => count($symptoms)
    ]);
} else {
    error_log("No symptoms found for age group: $age_group");
    
    // Check if table is empty or age_group values are wrong
    $check_sql = "SELECT DISTINCT age_group FROM symptoms";
    $check_result = $conn->query($check_sql);
    $available_groups = [];
    
    if ($check_result) {
        while ($group = $check_result->fetch_assoc()) {
            $available_groups[] = "'" . $group['age_group'] . "'";
        }
    }
    
    error_log("Available age groups in database: " . implode(", ", $available_groups));
    
    echo json_encode([
        "success" => false,
        "message" => "No symptoms found for age group: $age_group",
        "requested_age" => $age,
        "age_group" => $age_group,
        "available_groups" => $available_groups
    ]);
}

$stmt->close();
$conn->close();
?>