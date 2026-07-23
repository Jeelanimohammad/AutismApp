<?php
include 'config.php';

$queries = [
    "ALTER TABLE patients ADD COLUMN IF NOT EXISTS patient_id varchar(50) DEFAULT NULL",
    "ALTER TABLE patients ADD COLUMN IF NOT EXISTS sex varchar(10) DEFAULT NULL",
    "ALTER TABLE patients ADD COLUMN IF NOT EXISTS phone varchar(15) DEFAULT NULL",
    "ALTER TABLE patients ADD COLUMN IF NOT EXISTS password varchar(255) NOT NULL DEFAULT ''"
];

foreach ($queries as $q) {
    if ($conn->query($q)) {
        echo "Success: $q\n";
    } else {
        echo "Warning/Error for $q: " . $conn->error . "\n";
    }
}
$conn->close();
?>
