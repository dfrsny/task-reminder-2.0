<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Include database configuration
include 'config.php';

// Validasi parameter username
if (isset($_GET['username'])) {
    $username = mysqli_real_escape_string($connection, $_GET['username']);

    // Mengambil task_limit dari tabel users untuk username yang diberikan
    $query = "SELECT task_limit FROM users WHERE username = '$username'";
    $result = mysqli_query($connection, $query);

    if ($result) {
        $row = mysqli_fetch_assoc($result);
        if ($row) {
            echo json_encode([
                'status' => 'success',
                'task_limit' => $row['task_limit'],  // Mengirimkan task_limit
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'User not found.',
            ]);
        }
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to fetch task limit.',
            'error' => mysqli_error($connection),
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Username parameter is missing.',
    ]);
}

// Tutup koneksi database
mysqli_close($connection);
?>
