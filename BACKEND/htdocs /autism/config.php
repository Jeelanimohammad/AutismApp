<?php
// Database connection
$host = "127.0.0.1";
$user = "root"; // change if needed
$pass = "";     // set your MySQL password
$db   = "autism";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed"]));
}
