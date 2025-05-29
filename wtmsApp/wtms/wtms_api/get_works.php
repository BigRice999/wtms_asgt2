<?php
header('Content-Type: application/json');
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!isset($_POST['worker_id'])) {
        echo json_encode(['status' => 'fail', 'message' => 'worker_id is missing']);
        exit;
    }

    $worker_id = $_POST['worker_id'];

    $sql = "SELECT * FROM tbl_works WHERE assigned_to = ?";
    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        echo json_encode(['status' => 'fail', 'message' => 'SQL prepare failed']);
        exit;
    }

    $stmt->bind_param("i", $worker_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $tasks = [];
    while ($row = $result->fetch_assoc()) {
        $tasks[] = $row;
    }

    echo json_encode($tasks);
} else {
    echo json_encode(['status' => 'fail', 'message' => 'Invalid request method']);
}