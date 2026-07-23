<?php
include 'config.php';

$updates = [
    'Delayed Speech' => 'uploads/speech.png',
    'Lack of eye contact' => 'uploads/eye_contact.png',
    'Repetitive Behaviors' => 'uploads/repetitive.png',
    'Avoids eye contact' => 'uploads/eye_contact.png',
    'Does not respond to name' => 'uploads/speech.png', // Fallback for now or generate more later
    'No big smiles' => 'uploads/image_01.png',
    'No babbling' => 'uploads/image_02.png'
];

foreach ($updates as $name => $url) {
    $stmt = $conn->prepare("UPDATE symptoms SET image_url = ? WHERE symptom_name = ?");
    $stmt->bind_param("ss", $url, $name);
    $stmt->execute();
    echo "Updated $name to $url (" . $stmt->affected_rows . " rows)\n";
}
?>
