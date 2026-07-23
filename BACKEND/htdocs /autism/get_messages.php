<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

include 'config.php';

$sender_id = isset($_GET['user1']) ? $conn->real_escape_string($_GET['user1']) : '';
$receiver_id = isset($_GET['user2']) ? $conn->real_escape_string($_GET['user2']) : '';
$role = isset($_GET['role']) ? $_GET['role'] : '';

if ($sender_id && $receiver_id) {
    // Update sender status
    if ($role == 'doctor') {
        $conn->query("UPDATE doctors SET last_seen = NOW() WHERE doctor_id = '$sender_id'");
        $res = $conn->query("SELECT last_seen FROM patients WHERE patient_id = '$receiver_id'");
    } else {
        $conn->query("UPDATE patients SET last_seen = NOW() WHERE patient_id = '$sender_id'");
        $res = $conn->query("SELECT last_seen FROM doctors WHERE doctor_id = '$receiver_id'");
    }

    $is_online = false;
    if ($res && $row = $res->fetch_assoc()) {
        $last_seen_time = strtotime($row['last_seen']);
        if (time() - $last_seen_time < 120) { // 2 minutes
            $is_online = true;
        }
    }

    // Get messages between two users (either direction)
    $sql = "SELECT * FROM messages 
            WHERE (sender_id = '$sender_id' AND receiver_id = '$receiver_id') 
            OR (sender_id = '$receiver_id' AND receiver_id = '$sender_id') 
            ORDER BY created_at ASC";
            
    $result = $conn->query($sql);
    $messages = [];
    
    if ($result && $result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $messages[] = $row;
        }
    }
    
    // Mark as read if user2 is the receiver in the query but is the requester now (simple logic)
    // For now, just return messages.
    
    echo json_encode(["success" => true, "is_online" => $is_online, "messages" => $messages]);
} else {
    echo json_encode(["success" => false, "message" => "Missing parameters"]);
}

$conn->close();
?>
