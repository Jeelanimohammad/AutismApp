<?php
include 'config.php';

// Wipe existing symptoms for a clean slate
$conn->query("SET FOREIGN_KEY_CHECKS = 0");
$conn->query("TRUNCATE TABLE symptoms");
$conn->query("SET FOREIGN_KEY_CHECKS = 1");

$symptoms = [
    // --- AGE: BELOW 3 YEARS (7 symptoms) ---
    ["Child is not looking at the direction point",          "Early Signs", "<3", "uploads/image_01.png"],
    ["Child is not sharing things when asked",               "Early Signs", "<3", "uploads/image_02.png"],
    ["My child is not imitating my actions",                 "Early Signs", "<3", "uploads/image_06.png"],
    ["Child is finding difficult to express smile",          "Early Signs", "<3", "uploads/image_07.png"],
    ["Has poor eye contact",                                 "Early Signs", "<3", "uploads/image_04.png"],
    ["Child is finding it difficult to understand gestures", "Early Signs", "<3", "uploads/image_05.png"],
    ["My child prefers to be alone",                         "Early Signs", "<3", "uploads/image_08.png"],

    // --- AGE: ABOVE 3 YEARS (9 symptoms) ---
    ["Child is very attached to toys and other things",      "Older Children", ">3", "uploads/image_08.png"],
    ["Sometimes it feels like child can't hear well",        "Older Children", ">3", "uploads/image_09.png"],
    ["Child grabs elders hands to his/her point of interest","Older Children", ">3", "uploads/image_10.png"],
    ["Child has poor eye contact",                           "Older Children", ">3", "uploads/image_05.png"],
    ["Child has abnormal gestures and behaviour",            "Older Children", ">3", "uploads/image_06.png"],
    ["Child prefers to be alone",                            "Older Children", ">3", "uploads/image_01.png"],
    ["Child does not like to be hugged or touched",          "Older Children", ">3", "uploads/image_07.png"],
    ["Child does not involve in imaginative play",           "Older Children", ">3", "uploads/image_02.png"],
    ["Child exhibits strange or savant abilities",           "Older Children", ">3", "uploads/image_03.png"],
];

$inserted = 0;
foreach ($symptoms as $s) {
    $stmt = $conn->prepare(
        "INSERT INTO symptoms (symptom_name, explanation, age_group, image_url) VALUES (?, ?, ?, ?)"
    );
    $stmt->bind_param("ssss", $s[0], $s[1], $s[2], $s[3]);
    if ($stmt->execute()) {
        $inserted++;
    }
}

echo json_encode([
    "success" => true,
    "inserted" => $inserted,
    "message" => "Repopulated $inserted symptoms: 7 for children under 3, 9 for children over 3."
]);
?>
