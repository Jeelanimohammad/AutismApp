<?php
include 'config.php';

// Wipe existing symptoms for a clean slate
$conn->query("SET FOREIGN_KEY_CHECKS = 0");
$conn->query("TRUNCATE TABLE symptoms");
$conn->query("SET FOREIGN_KEY_CHECKS = 1");

$symptoms = [
    // --- AGE: BELOW 3 YEARS (7 symptoms) ---
    [1, "Child is not looking at the direction point",          "Early Signs", "<3", "uploads/child1.png"],
    [2, "Child is not sharing things when asked",               "Early Signs", "<3", "uploads/child2.png"],
    [3, "My child is not imitating my actions",                 "Early Signs", "<3", "uploads/child3.png"],
    [4, "Child is finding difficult to express smile",          "Early Signs", "<3", "uploads/child4.png"],
    [5, "Has poor eye contact",                                 "Early Signs", "<3", "uploads/child5.png"],
    [6, "Child is finding it difficult to understand gestures", "Early Signs", "<3", "uploads/child6.png"],
    [7, "My child prefers to be alone",                         "Early Signs", "<3", "uploads/child7.png"],

    // --- AGE: ABOVE 3 YEARS (9 symptoms) ---
    [11, "Child does not involve in imaginative play",           "Older Children", ">3", "uploads/child11.png"],
    [12, "Sometimes it feels like child can't hear well",        "Older Children", ">3", "uploads/child12.png"],
    [13, "Child grabs elders hands to his/her point of interest","Older Children", ">3", "uploads/child13.png"],
    [14, "Child has poor eye contact",                           "Older Children", ">3", "uploads/child14.png"],
    [15, "Child has abnormal gestures and behaviour",            "Older Children", ">3", "uploads/child15.png"],
    [16, "Child prefers to be alone",                            "Older Children", ">3", "uploads/child16.png"],
    [17, "Child does not like to be hugged or touched",          "Older Children", ">3", "uploads/child17.png"],
    [18, "Child is not indulging in imaginative play",           "Older Children", ">3", "uploads/child18.png"],
    [19, "Child exhibits strange or savant abilities",           "Older Children", ">3", "uploads/child19.png"],
];

$inserted = 0;
foreach ($symptoms as $s) {
    $stmt = $conn->prepare(
        "INSERT INTO symptoms (id, symptom_name, explanation, age_group, image_url) VALUES (?, ?, ?, ?, ?)"
    );
    $stmt->bind_param("issss", $s[0], $s[1], $s[2], $s[3], $s[4]);
    if ($stmt->execute()) {
        $inserted++;
    }
}

echo json_encode([
    "success" => true,
    "inserted" => $inserted,
    "message" => "Repopulated $inserted symptoms with exact App IDs & images: 7 for children under 3, 9 for children over 3."
]);
?>
