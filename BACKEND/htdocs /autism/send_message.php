<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include 'config.php';

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['sender_id'], $data['receiver_id'], $data['sender_role'], $data['message_text'])) {
    $sender_id = $data['sender_id'];
    $receiver_id = $data['receiver_id'];
    $sender_role = $data['sender_role'];
    $message_text = $data['message_text'];

    $stmt = $conn->prepare("INSERT INTO messages (sender_id, receiver_id, sender_role, message_text) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $sender_id, $receiver_id, $sender_role, $message_text);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Message sent"]);
    } else {
        $err = "Failed to send message: " . $stmt->error;
        file_put_contents("debug_log.txt", date("[Y-m-d H:i:s] ") . $err . "\n", FILE_APPEND);
        echo json_encode(["success" => false, "message" => $err]);
    }
    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Invalid input data"]);
}

$conn->close();

function real_escape_with_null($conn, $val) {
    return ($val === null) ? null : $conn->real_escape_string($val);
}
?>
