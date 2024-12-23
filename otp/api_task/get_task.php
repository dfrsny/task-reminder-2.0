<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Include database configuration
include 'config.php';

// Validasi input
if (isset($_GET['username'])) {
    $username = mysqli_real_escape_string($connection, $_GET['username']);
    
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

    // Mengambil semua tugas dari tabel
    $query = "SELECT * FROM $taskTable";
    $result = mysqli_query($connection, $query);

    if ($result) {
        $tasks = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $tasks[] = $row;
        }
        echo json_encode([
            'status' => 'success',
            'tasks' => $tasks,
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to retrieve tasks.',
            'error' => mysqli_error($connection),
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Username is required.',
    ]);
}

// Close the database connection
mysqli_close($connection);
?>
