<?php
header("Content-Type: application/json");
include 'config.php';

$response = ["success" => true, "messages" => []];

// Check uploads directory
if (!file_exists('uploads')) {
    if (mkdir('uploads', 0777, true)) {
        $response["messages"][] = "Created uploads directory";
    } else {
        $response["success"] = false;
        $response["messages"][] = "Failed to create uploads directory";
    }
} else {
    $response["messages"][] = "Uploads directory exists";
    if (is_writable('uploads')) {
        $response["messages"][] = "Uploads directory is writable";
    } else {
        chmod('uploads', 0777);
        if (is_writable('uploads')) {
            $response["messages"][] = "Fixed uploads directory permissions";
        } else {
            $response["success"] = false;
            $response["messages"][] = "Uploads directory is NOT writable";
        }
    }
}

// Check patients table columns
$result = $conn->query("SHOW COLUMNS FROM patients LIKE 'profile_image'");
if ($result->num_rows == 0) {
    if ($conn->query("ALTER TABLE patients ADD COLUMN profile_image VARCHAR(255) DEFAULT NULL")) {
        $response["messages"][] = "Added profile_image column to patients table";
    } else {
        $response["success"] = false;
        $response["messages"][] = "Failed to add profile_image column: " . $conn->error;
    }
} else {
    $response["messages"][] = "profile_image column exists in patients table";
}

// Check doctors table columns
$result = $conn->query("SHOW COLUMNS FROM doctors LIKE 'profile_image'");
if ($result->num_rows == 0) {
    if ($conn->query("ALTER TABLE doctors ADD COLUMN profile_image VARCHAR(255) DEFAULT NULL")) {
        $response["messages"][] = "Added profile_image column to doctors table";
    } else {
        $response["success"] = false;
        $response["messages"][] = "Failed to add profile_image column to doctors: " . $conn->error;
    }
} else {
    $response["messages"][] = "profile_image column exists in doctors table";
}

echo json_encode($response);
$conn->close();
?>
