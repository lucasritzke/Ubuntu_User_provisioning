<?php
if (isset($_POST['username']) && isset($_POST['password']) && isset($_POST['userID']) && isset($_POST['email']) && isset($_POST['name']) && isset($_POST['office']) && isset($_POST['userType']) && isset($_POST['admissionDay'])) {
    $username_input = $_POST['username'];
    $password_input = $_POST['password'];
    $userID = $_POST['userID'];
    $email = $_POST['email'];
    $name = $_POST['name'];
    $office = $_POST['office'];
    $userType = $_POST['userType'];
    $admissionDay = $_POST['admissionDay'];

    $servername = "localhost";
    $db_username = "lritzke";
    $db_password = "lritzke";
    $dbname = "spreadsheet";

    $conn = new mysqli($servername, $db_username, $db_password, $dbname);

    if ($conn->connect_error) {
        die("Erro na conexão com o banco de dados: " . $conn->connect_error);
    }

    $stmt = $conn->prepare("UPDATE collaborator_information SET email=?, name=?, office=?, user_type=?, admission_day=? WHERE UserID=?");
    $stmt->bind_param("ssssss", $email, $name, $office, $userType, $admissionDay, $userID);

    if ($stmt->execute()) {
        echo "Upload realizado com sucesso!";
    } else {
        echo "Erro ao realizar o upload: " . $stmt->error;
    }

    $stmt->close();
    $conn->close();
}
?>

