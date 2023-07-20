<!DOCTYPE html>
<html>
<center>
      <nav>
          <a href="index.php">Spreadsheet</a>
          <a href="upload.php">Upload</a>
      </nav>
</center>
<center>
<br>
<br>
<head>
    <title>display data</title>
    <style>
        table {
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
        }
    </style>
</head>
<body>
    <table>
        <tr>
            <th>UserID</th>
            <th>Email</th>
            <th>Name</th>
            <th>office</th>
            <th>User type</th>
            <th>Admission day</th>
        </tr>
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

        // Executa a consulta
        $sql = "SELECT * FROM collaborator_information";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                echo "<tr>";
                echo "<td>" . $row["UserID"] . "</td>";
                echo "<td>" . $row["email"] . "</td>";
                echo "<td>" . $row["name"] . "</td>";
                echo "<td>" . $row["office"] . "</td>";
                echo "<td>" . $row["user_type"] . "</td>";
                echo "<td>" . $row["admission_day"] . "</td>";
                echo "</tr>";
            }
        } else {
            echo "<tr><td colspan='6'>Nenhum resultado encontrado.</td></tr>";
        }

        // Fecha a conexão com o banco de dados
        $conn->close();
        ?>
    </table>
</body>
</center>
</html>

