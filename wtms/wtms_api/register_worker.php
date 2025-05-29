<?php
include("db_connect.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $full_name = $_POST['full_name'];
    $email = $_POST['email'];
    $password = sha1($_POST['password']); // hash password
    $phone = $_POST['phone'];
    $address = $_POST['address'];

    if (!$full_name || !$email || !$password || !$phone || !$address) {
        echo json_encode(["status" => "error", "message" => "Missing required fields."]);
        exit();
    }

    $sql = "INSERT INTO workerinfo (full_name, email, password, phone, address)
            VALUES ('$full_name', '$email', '$password', '$phone', '$address')";

    if (mysqli_query($conn, $sql)) {
        echo json_encode(["status" => "success", "message" => "Worker registered successfully!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "ERROR! Something goes wrong"]);
    }
}

    $imagePath = "";
    if (isset($_FILES['image'])) {
        $image = $_FILES['image']['name'];
        $tempPath = $_FILES['image']['tmp_name'];
        $uploadPath = 'uploads/' . $image;
        move_uploaded_file($tempPath, $uploadPath);
        $imagePath = $uploadPath;
    }

    $sql = "INSERT INTO workerinfo (full_name, email, password, phone, address, image)
        VALUES ('$full_name', '$email', '$password', '$phone', '$address', '$imagePath')";

?>
