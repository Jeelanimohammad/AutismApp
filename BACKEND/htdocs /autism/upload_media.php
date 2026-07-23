<?php
header("Content-Type: application/json");
include "config.php";

$target_dir = "uploads/";
if (!file_exists($target_dir)) {
    mkdir($target_dir, 0777, true);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['file'])) {
    $file = $_FILES['file'];
    $file_extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $new_filename = time() . "_" . uniqid() . "." . $file_extension;
    $target_file = $target_dir . $new_filename;

    if (move_uploaded_file($file['tmp_name'], $target_file)) {
        $actual_link = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://$_SERVER[HTTP_HOST]/autism/$target_file";
        echo json_encode([
            "success" => true,
            "url" => $actual_link,
            "filename" => $new_filename
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Upload failed"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "No file uploaded"]);
}
?>
