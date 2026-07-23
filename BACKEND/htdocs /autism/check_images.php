<?php
include 'config.php';
$res = $conn->query("SELECT symptom_name, image_url FROM symptoms LIMIT 10");
while($row = $res->fetch_assoc()) {
    echo $row['symptom_name'] . " -> " . $row['image_url'] . "\n";
}
?>
