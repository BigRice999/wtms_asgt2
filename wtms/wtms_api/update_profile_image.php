<?php
include("db_connect.php");
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $workerId = $_POST['id'];

    if (isset($_FILES['image'])) {
        $image = $_FILES['image']['name'];
        $tempPath = $_FILES['image']['tmp_name'];
        $uploadPath = "uploads/" . uniqid() . "_" . basename($image);

        if (move_uploaded_file($tempPath, $uploadPath)) {
            $sql = "UPDATE workerinfo SET image = '$uploadPath' WHERE id = '$workerId'";
            if (mysqli_query($conn, $sql)) {
                echo json_encode(["status" => "success", "image" => $uploadPath]);
            } else {
                echo json_encode(["status" => "error", "message" => "Failed to update database"]);
            }
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to move uploaded file"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "No image uploaded"]);
    }
}
?>
