<?php
include 'config.php';

$sql = "ALTER TABLE patients ADD COLUMN profile_image VARCHAR(255) DEFAULT NULL";
if ($conn->query($sql) === TRUE) {
    echo "Column profile_image added successfully";
} else {
    echo "Error adding column: " . $conn->error;
}
$conn->close();
?>
