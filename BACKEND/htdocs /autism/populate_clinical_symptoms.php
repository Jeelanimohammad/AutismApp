<?php
include 'config.php';

// Disable FK checks to allow truncate
$conn->query("SET FOREIGN_KEY_CHECKS = 0");
$conn->query("TRUNCATE TABLE symptoms");
$conn->query("SET FOREIGN_KEY_CHECKS = 1");

$symptoms = [
    // --- AGE GROUP: < 3 YEARS (TODDLERS) ---
    [
        'name' => 'Response to Name',
        'exp' => 'Does your child look when you call their name?',
        'age' => '<3',
        'img' => 'uploads/name_response.png'
    ],
    [
        'name' => 'Joint Attention (Pointing)',
        'exp' => 'Does your child point to show you something they are interested in?',
        'age' => '<3',
        'img' => 'uploads/pointing.png'
    ],
    [
        'name' => 'Eye Contact',
        'exp' => 'Does your child make eye contact during interaction?',
        'age' => '<3',
        'img' => 'uploads/eye_contact.png'
    ],
    [
        'name' => 'Smiling Back',
        'exp' => 'Does your child smile back when you smile at them?',
        'age' => '<3',
        'img' => 'uploads/smile_back.png'
    ],
    [
        'name' => 'Delayed Babbling',
        'exp' => 'Is your child babbling or using single words yet?',
        'age' => '<3',
        'img' => 'uploads/speech.png'
    ],
    
    // --- AGE GROUP: > 3 YEARS (OLDER CHILDREN) ---
    [
        'name' => 'Social Interaction',
        'exp' => 'Does your child prefer to play alone rather than with other children?',
        'age' => '>3',
        'img' => 'uploads/social_isolation.png'
    ],
    [
        'name' => 'Routine Rigidity',
        'exp' => 'Does your child get extremely upset by minor changes in their routine?',
        'age' => '>3',
        'img' => 'uploads/routine.png'
    ],
    [
        'name' => 'Repetitive Movements',
        'exp' => 'Does your child exhibit repetitive movements (e.g., hand flapping, spinning)?',
        'age' => '>3',
        'img' => 'uploads/repetitive.png'
    ],
    [
        'name' => 'Sensory Sensitivity',
        'exp' => 'Does your child overreact to normal sounds (e.g., vacuum cleaner) or textures?',
        'age' => '>3',
        'img' => 'uploads/sensory.png'
    ],
    [
        'name' => 'Specialized Interests',
        'exp' => 'Does your child have an unusually intense focus on specific objects or topics?',
        'age' => '>3',
        'img' => 'uploads/interests.png'
    ]
];

foreach ($symptoms as $s) {
    $stmt = $conn->prepare("INSERT INTO symptoms (symptom_name, explanation, age_group, image_url) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $s['name'], $s['exp'], $s['age'], $s['img']);
    $stmt->execute();
}

echo "Database successfully updated with clinical symptoms for all ages.\n";
?>
