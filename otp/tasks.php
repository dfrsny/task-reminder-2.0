<?php
include 'config.php';

// Menambahkan tugas baru
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $username = $data['username'];
    $taskName = $data['task_name'];
    $deadline = $data['deadline'];

    // Buat tabel tasks_ jika belum ada
    $tableName = "tasks_" . $username;
    $checkTableQuery = "SHOW TABLES LIKE '$tableName'";
    $result = $conn->query($checkTableQuery);
    if ($result->num_rows == 0) {
        $createTableQuery = "CREATE TABLE $tableName (
            id INT AUTO_INCREMENT PRIMARY KEY,
            task_name VARCHAR(255) NOT NULL,
            deadline DATETIME NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )";
        $conn->query($createTableQuery);
    }

    // Insert task
    $insertQuery = "INSERT INTO $tableName (task_name, deadline) VALUES ('$taskName', '$deadline')";
    if ($conn->query($insertQuery) === TRUE) {
        echo json_encode(["status" => "success", "message" => "Task added successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error: " . $conn->error]);
    }
}

// Mendapatkan semua tugas
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $username = $_GET['username'];
    $tableName = "tasks_" . $username;

    $selectQuery = "SELECT * FROM $tableName";
    $result = $conn->query($selectQuery);

    $tasks = [];
    while ($row = $result->fetch_assoc()) {
        $tasks[] = $row;
    }
    echo json_encode($tasks);
}

// Mengupdate tugas
if ($_SERVER['REQUEST_METHOD'] == 'PUT') {
    $data = json_decode(file_get_contents('php://input'), true);
    $username = $data['username'];
    $taskId = $data['task_id'];
    $taskName = $data['task_name'];
    $deadline = $data['deadline'];

    $tableName = "tasks_" . $username;

    $updateQuery = "UPDATE $tableName SET task_name = '$taskName', deadline = '$deadline' WHERE id = $taskId";
    if ($conn->query($updateQuery) === TRUE) {
        echo json_encode(["status" => "success", "message" => "Task updated successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error: " . $conn->error]);
    }
}

// Menghapus tugas
if ($_SERVER['REQUEST_METHOD'] == 'DELETE') {
    $data = json_decode(file_get_contents('php://input'), true);
    $username = $data['username'];
    $taskId = $data['task_id'];

    $tableName = "tasks_" . $username;

    $deleteQuery = "DELETE FROM $tableName WHERE id = $taskId";
    if ($conn->query($deleteQuery) === TRUE) {
        echo json_encode(["status" => "success", "message" => "Task deleted successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error: " . $conn->error]);
    }
}

$conn->close();
?>
