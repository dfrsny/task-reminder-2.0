<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Include database configuration
include 'config.php';

// Validasi input
if (isset($_POST['username']) && isset($_POST['judul_task']) && isset($_POST['description']) && isset($_POST['deadline'])) {
    $username = mysqli_real_escape_string($connection, $_POST['username']);
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

    // Memeriksa dan mengurangi task_limit
    $taskLimitQuery = "SELECT task_limit FROM users WHERE username = '$username'";
    $taskLimitResult = mysqli_query($connection, $taskLimitQuery);
    $taskLimit = mysqli_fetch_assoc($taskLimitResult)['task_limit'];

    if ($taskLimit <= 0) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Task limit reached. Cannot add more tasks.',
        ]);
        exit;
    }

    // Menambah tugas baru ke dalam tabel
    $query = "INSERT INTO $taskTable (judul_task, description, deadline) VALUES ('$judul_task', '$description', '$deadline')";
    $result = mysqli_query($connection, $query);

    if ($result) {
        // Mengurangi task limit setelah berhasil menambah tugas
        $newTaskLimit = $taskLimit - 1;
        $updateLimitQuery = "UPDATE users SET task_limit = $newTaskLimit WHERE username = '$username'";
        mysqli_query($connection, $updateLimitQuery);

        echo json_encode([
            'status' => 'success',
            'message' => 'Task added successfully.',
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to add task.',
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
