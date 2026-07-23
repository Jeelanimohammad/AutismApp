<?php
include 'config.php';

/* 🔍 GET PATIENT FCM TOKEN */
function getPatientFcmToken($patientId) {
    global $conn;

    $stmt = $conn->prepare(
        "SELECT fcm_token FROM patients WHERE patient_id = ?"
    );

    if (!$stmt) {
        return null; // prevent crash
    }

    $stmt->bind_param("s", $patientId);
    $stmt->execute();
    $res = $stmt->get_result();

    if ($row = $res->fetch_assoc()) {
        return $row['fcm_token'];
    }

    return null;
}

/* 🔔 SEND PUSH NOTIFICATION */
function sendNotificationToPatient($patientId, $title, $body) {

    $token = getPatientFcmToken($patientId);

    if (!$token) {
        return; // no token → skip silently
    }

    $payload = [
        "to" => $token,
        "notification" => [
            "title" => $title,
            "body"  => $body
        ]
    ];

    $headers = [
        "Authorization: key=YOUR_FCM_SERVER_KEY",
        "Content-Type: application/json"
    ];

    $ch = curl_init("https://fcm.googleapis.com/fcm/send");
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    curl_exec($ch);
    curl_close($ch);
}
