<?php
header("Content-Type: application/json");
echo json_encode([
    "message" => "Server Path Check",
    "absolute_path" => __FILE__,
    "server_name" => $_SERVER['SERVER_NAME'],
    "document_root" => $_SERVER['DOCUMENT_ROOT']
]);
?>
