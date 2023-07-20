<?php
$servername = "localhost";
$username = "lritzke";
$password = "lritzke";
$dbname = "spreadsheet";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Erro na conexão com o banco de dados: " . $conn->connect_error);
}

$name_user = $_GET['name_user'];

$stmt = $conn->prepare("SELECT * FROM collaborator_information WHERE UserID = ?");
$stmt->bind_param("s", $name_user);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    $response = [
        'notFound' => false,
        'user' => $user
    ];
} else {
    $response = [
        'notFound' => true
    ];
}

$stmt->close();
$conn->close();

echo json_encode($response);
