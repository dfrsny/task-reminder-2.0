<?php
header("Content-Type: application/json");
include 'config.php'; // Mengimpor konfigurasi untuk koneksi ke database MySQL

// Mendapatkan metode HTTP (GET, POST, PUT, DELETE)
$method = $_SERVER['REQUEST_METHOD'];

// Handle API request berdasarkan metode HTTP
switch ($method) {
    case 'GET':
        // Mendapatkan daftar tugas berdasarkan user_id
        if (isset($_GET['user_id'])) {
            $user_id = $_GET['user_id'];
            $query = "SELECT * FROM tasks WHERE user_id = ? ORDER BY created_at DESC";
            $stmt = mysqli_prepare($connection, $query);
            mysqli_stmt_bind_param($stmt, "i", $user_id);  // "i" menunjukkan bahwa parameter user_id adalah integer
            mysqli_stmt_execute($stmt);
            $result = mysqli_stmt_get_result($stmt);

            $tasks = [];
            while ($task = mysqli_fetch_assoc($result)) {
                $tasks[] = $task;
            }

            if (!empty($tasks)) {
                echo json_encode($tasks); // Mengembalikan data tugas dalam format JSON
            } else {
                echo json_encode(['error' => 'No tasks found for this user']);
            }

            mysqli_stmt_close($stmt);
        } else {
            echo json_encode(['error' => 'User ID is required']);
        }
        break;

    case 'POST':
        // Menambahkan tugas baru
        if (isset($_POST['user_id']) && isset($_POST['description']) && isset($_POST['deadline'])) {
            $user_id = $_POST['user_id'];
            $description = $_POST['description'];
            $deadline = $_POST['deadline'];

            $query = "INSERT INTO tasks (user_id, description, deadline) VALUES (?, ?, ?)";
            $stmt = mysqli_prepare($connection, $query);
            mysqli_stmt_bind_param($stmt, "iss", $user_id, $description, $deadline);  // "iss" menunjukkan bahwa user_id adalah integer, dan description serta deadline adalah string

            if (mysqli_stmt_execute($stmt)) {
                echo json_encode(['success' => true, 'message' => 'Task added successfully']);
            } else {
                echo json_encode(['error' => 'Failed to add task']);
            }

            mysqli_stmt_close($stmt);
        } else {
            echo json_encode(['error' => 'Missing parameters']);
        }
        break;

    case 'PUT':
        // Mengupdate tugas yang sudah ada
        parse_str(file_get_contents("php://input"), $_PUT);

        if (isset($_PUT['id']) && isset($_PUT['description']) && isset($_PUT['deadline'])) {
            $id = $_PUT['id'];
            $description = $_PUT['description'];
            $deadline = $_PUT['deadline'];

            $query = "UPDATE tasks SET description = ?, deadline = ? WHERE id = ?";
            $stmt = mysqli_prepare($connection, $query);
            mysqli_stmt_bind_param($stmt, "ssi", $description, $deadline, $id);  // "ssi" menunjukkan bahwa description dan deadline adalah string, id adalah integer

            if (mysqli_stmt_execute($stmt)) {
                echo json_encode(['success' => true, 'message' => 'Task updated successfully']);
            } else {
                echo json_encode(['error' => 'Failed to update task']);
            }

            mysqli_stmt_close($stmt);
        } else {
            echo json_encode(['error' => 'Missing parameters']);
        }
        break;

    case 'DELETE':
        // Menghapus tugas berdasarkan ID
        if (isset($_GET['id'])) {
            $id = $_GET['id'];
            $query = "DELETE FROM tasks WHERE id = ?";
            $stmt = mysqli_prepare($connection, $query);
            mysqli_stmt_bind_param($stmt, "i", $id);  // "i" menunjukkan bahwa parameter id adalah integer

            if (mysqli_stmt_execute($stmt)) {
                echo json_encode(['success' => true, 'message' => 'Task deleted successfully']);
            } else {
                echo json_encode(['error' => 'Failed to delete task']);
            }

            mysqli_stmt_close($stmt);
        } else {
            echo json_encode(['error' => 'Task ID is required']);
        }
        break;

    default:
        echo json_encode(['error' => 'Method not allowed']);
        break;
}

// Menutup koneksi database
mysqli_close($connection);
?>
