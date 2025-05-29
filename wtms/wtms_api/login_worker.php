<?php
include("db_connect.php");

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $email = $_POST['email'];
    $password = sha1($_POST['password']);

    if (!$email || !$password) {
        echo json_encode(["status" => "error", "message" => "Missing fields"]);
        exit();
    }

    $sql = "SELECT * FROM workerinfo WHERE email = '$email' AND password = '$password'";
    $result = mysqli_query($conn, $sql);

    if ($result && mysqli_num_rows($result) == 1) {
        $row = mysqli_fetch_assoc($result);
        echo json_encode([
            "status" => "success",
            "data" => $row
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Invalid credentials"
        ]);
    }
}
?>
