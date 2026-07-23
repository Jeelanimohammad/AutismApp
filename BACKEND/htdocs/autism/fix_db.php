<?php
include 'config.php';

$queries = [
    "ALTER TABLE symptom_responses ADD COLUMN IF NOT EXISTS assessment_id INT AFTER patient_id",
    "ALTER TABLE doctor_advice ADD COLUMN IF NOT EXISTS assessment_id INT AFTER advice_text"
];

echo "Database Fixer started...<br>";

foreach ($queries as $sql) {
    if ($conn->query($sql)) {
        echo "Successfully executed: $sql <br>";
    } else {
        echo "Error: " . $conn->error . "<br>";
    }
}

$conn->close();
echo "Done!";
?>
