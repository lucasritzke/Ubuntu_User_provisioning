<?php
$servername = "localhost";
$username = "lritzke";
$password = "lritzke";
$database = "spreadsheet";

$conn = new mysqli($servername, $username, $password, $database);

// Verifica a conexão
if ($conn->connect_error) {
    die("Erro na conexão com o banco de dados: " . $conn->connect_error);
}

$name_user = $_GET['name'];

// Executa a consulta
$sql = "SELECT * FROM collaborator_information WHERE UserID='" . $name_user . "'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        echo "-------------------------------------" . "<br>";
        echo "UserID: " . $row["UserID"] . "<br>";
        echo "Email: " . $row["email"] . "<br>";
        echo "Nome: " . $row["name"] . "<br>";
        echo "Cargo: " . $row["office"] . "<br>";
        echo "Tipo de Usuário: " . $row["user_type"] . "<br>";
        echo "Data de Admissão: " . $row["admission_day"] . "<br>";
        echo "<br>";
    }
} else {
    echo "Nenhum resultado encontrado.";
}

// Fecha a conexão com o banco de dados
$conn->close();
?>

