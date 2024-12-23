<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Include database configuration
include 'config.php';

// Validasi input
if (isset($_POST['username']) && isset($_POST['id'])) {
    $username = mysqli_real_escape_string($connection, $_POST['username']);
    $id = mysqli_real_escape_string($connection, $_POST['id']);

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

    // Menghapus tugas
    $query = "DELETE FROM $taskTable WHERE id = $id";
    $result = mysqli_query($connection, $query);

    if ($result) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Task deleted successfully.',
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to delete task.',
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
