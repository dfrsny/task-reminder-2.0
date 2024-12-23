<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

include "config.php";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $username_or_email = $input['username_or_email'] ?? '';
    $password = $input['password'] ?? '';

    $stmt = $connection->prepare("SELECT * FROM users WHERE username=? OR email=?");
    $stmt->bind_param("ss", $username_or_email, $username_or_email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        if (password_verify($password, $user['password'])) {
            echo json_encode([
                'success' => true,
                'message' => 'Login Berhasil!',
                'data' => [
                    'id' => $user['id'] ?? '',
                    'username' => $user['username'] ?? '',
                    'nomor' => $user['phone'] ?? '',
                    'email' => $user['email'] ?? ''
                ]
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Invalid password'
            ]);
        }
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'User not found'
        ]);
    }

    $stmt->close();
    $connection->close();
} else {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Only POST requests are allowed'
    ]);
}
?>
