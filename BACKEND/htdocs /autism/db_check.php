<?php
header("Content-Type: application/json");
include 'config.php';

$tables = [];
$result = $conn->query("SHOW TABLES");
while ($row = $result->fetch_array()) {
    $tableName = $row[0];
    $countRes = $conn->query("SELECT COUNT(*) FROM `$tableName` text");
    $count = ($countRes) ? $countRes->fetch_array()[0] : "Error";
    $tables[$tableName] = $count;
}

echo json_encode([
    "success" => true,
    "database" => $db,
    "tables" => $tables,
    "connection_info" => [
        "host" => $host,
        "user" => $user
    ]
]);
?>
