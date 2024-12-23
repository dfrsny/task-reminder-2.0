<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Include database configuration
include 'config.php';

// Validasi input
if (isset($_POST['username']) && isset($_POST['id']) && isset($_POST['judul_task']) && isset($_POST['description']) && isset($_POST['deadline'])) {
    $username = mysqli_real_escape_string($connection, $_POST['username']);
    $id = mysqli_real_escape_string($connection, $_POST['id']);
    $judul_task = mysqli_real_escape_string($connection, $_POST['judul_task']);
    $description = mysqli_real_escape_string($connection, $_POST['description']);
    $deadline = mysqli_real_escape_string($connection, $_POST['deadline']);

    // Memastikan tabel tugas untuk username sudah ada
    $taskTable = "tasks_$username";
    $checkTableQuery = "SHOW TABLES LIKE '$taskTable'";
    $checkTableResult = mysqli_query($connection, $checkTableQuery);

    if (mysqli_num_rows($checkTableResult) == 0) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Task table not found for user $username.',
        ]);
        exit;
    }

    // Mengedit tugas
    $query = "UPDATE $taskTable SET judul_task = '$judul_task', description = '$description', deadline = '$deadline' WHERE id = $id";
    $result = mysqli_query($connection, $query);

    if ($result) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Task updated successfully.',
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to update task.',
            'error' => mysqli_error($connection),
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Invalid input. Please provide all required fields.',
    ]);
}

// Close the database connection
mysqli_close($connection);
?>
