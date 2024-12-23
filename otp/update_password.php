<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Content-Type: application/json');
include 'config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nomor = mysqli_real_escape_string($connection, $_POST['nomor']);
    $password = mysqli_real_escape_string($connection, $_POST['password']);

    // Debug: Cek apakah nomor dan password diterima dengan benar
    error_log("Nomor: $nomor, Password: $password");

    // Validasi input
    if (empty($nomor) || empty($password)) {
        echo json_encode(["status" => "error", "message" => "Nomor dan password tidak boleh kosong."]);
        exit;
    }

    // Hash password
    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

    // Gunakan prepared statement untuk mencegah SQL Injection
    $query = "UPDATE users SET password = ? WHERE phone = ?";
    $stmt = mysqli_prepare($connection, $query);
    if ($stmt) {
        mysqli_stmt_bind_param($stmt, "ss", $hashedPassword, $nomor);
        $result = mysqli_stmt_execute($stmt);

        if ($result) {
            echo json_encode(["status" => "success", "message" => "Password berhasil diperbarui."]);
        } else {
            echo json_encode(["status" => "error", "message" => "Error: " . mysqli_stmt_error($stmt)]);
        }

        mysqli_stmt_close($stmt);
    } else {
        echo json_encode(["status" => "error", "message" => "Error preparing statement: " . mysqli_error($connection)]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
?>
