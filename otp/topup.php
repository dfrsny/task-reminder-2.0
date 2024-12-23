<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

include "config.php";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'] ?? '';
    $task_amount = intval($_POST['task_amount'] ?? 0);

    if (empty($username) || $task_amount <= 0) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Invalid input',
        ]);
        exit;
    }

    $stmt = $connection->prepare("SELECT task_limit FROM users WHERE username = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        $current_task_limit = intval($user['task_limit']);

        $new_task_limit = $current_task_limit + $task_amount;

        $update_stmt = $connection->prepare("UPDATE users SET task_limit = ? WHERE username = ?");
        $update_stmt->bind_param("is", $new_task_limit, $username);

        if ($update_stmt->execute()) {
            echo json_encode([
                'status' => 'success',
                'message' => 'Task limit updated successfully',
                'new_task_limit' => $new_task_limit,
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Failed to update task limit',
            ]);
        }

        $update_stmt->close();
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'User not found',
        ]);
    }

    $stmt->close();
    $connection->close();
} else {
    http_response_code(405);
    echo json_encode([
        'status' => 'error',
        'message' => 'Only POST requests are allowed',
    ]);
}
