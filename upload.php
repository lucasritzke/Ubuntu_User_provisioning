<!DOCTYPE html>
<html>
<head>
<script>
function buscarInformacoes() {
    var name_user = document.getElementById('search_name').value;
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            var response = JSON.parse(this.responseText);
            if (!response.notFound) {
                exibirFormulario(response.user);
            } else {
                document.getElementById("resultado").innerHTML = "Nenhum resultado encontrado.";
                document.getElementById("formulario").innerHTML = "";
            }
        }
    };
    xhttp.open("GET", "informacoes.php?name_user=" + name_user, true);
    xhttp.send();
}

function exibirFormulario(user) {
    var formHtml = `
	<label>----------------------------------------------------------------------------------------------------------------------------------</label>
	<br />
        <label for="username">Username:</label>
        <input type="text" id="username" value="lritzke" />
        <br />
        <label for="password">Password:</label>
        <input type="password" id="password" value="lritzke" />
        <br />
	<label>----------------------------------------------------------------------------------------------------------------------------------</label>
	<br />
        <input type="hidden" id="userID" value="${user.UserID}" />
        <label for="email">Email:</label>
        <input type="text" id="email" value="${user.email}" />
        <br />
        <label for="name">Name:</label>
	<input type="text" id="name" value="${user.name}" />
        <br />
        <label for="office">Office:</label>
        <input type="text" id="office" value="${user.office}" />
        <br />
        <label for="userType">user_type:</label>
        <input type="text" id="userType" value="${user.user_type}" />
        <br />
        <label for="admissionDay">Admission Day:</label>
        <input type="text" id="admissionDay" value="${user.admission_day}" />
        <br />
        <button onclick="fazerUpload()">Make Upload</button>
    `;
    document.getElementById("formulario").innerHTML = formHtml;
}

function fazerUpload() {
    var username = document.getElementById('username').value;
    var password = document.getElementById('password').value;
    var userID = document.getElementById('userID').value;
    var email = document.getElementById('email').value;
    var name = document.getElementById('name').value;
    var office = document.getElementById('office').value;
    var userType = document.getElementById('userType').value;
    var admissionDay = document.getElementById('admissionDay').value;

    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            document.getElementById("resultado").innerHTML = this.responseText;
        }
    };
    xhttp.open("POST", "atualizar_usuario.php", true);
    xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhttp.send("username=" + encodeURIComponent(username) +
               "&password=" + encodeURIComponent(password) +
               "&userID=" + encodeURIComponent(userID) +
               "&email=" + encodeURIComponent(email) +
               "&name=" + encodeURIComponent(name) +
               "&office=" + encodeURIComponent(office) +
               "&userType=" + encodeURIComponent(userType) +
               "&admissionDay=" + encodeURIComponent(admissionDay));
}
</script>
</head>
<body>
<center>
    <nav>
        <a href="index.php">Spreadsheet</a>
        <a href="upload.php">Upload</a>
    </nav>
</center>

<table>
    <tr>
        <td>
            <label for="name">Enter the name you want to search for information:</label>
            <input type="text" id="search_name" />
	    <br>
            <button onclick="buscarInformacoes()">Check</button>
	    <br>
	    <br>
        </td>
    </tr>
    <tr>
        <td>
            <div id="resultado"></div>
        </td>
    </tr>
    <tr>
        <td>
            <div id="formulario"></div>
        </td>
    </tr>
</table>

</body>
</html>

