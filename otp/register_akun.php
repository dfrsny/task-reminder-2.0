<?php
header('Access-Control-Allow-Origin: *'); // Mengizinkan akses dari semua origin
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json'); // Mengatur tipe konten sebagai JSON

include "config.php"; // Impor konfigurasi database

// Validasi input POST
if (
    isset($_POST['username']) && !empty($_POST['username']) &&
    isset($_POST['email']) && !empty($_POST['email']) &&
    isset($_POST['phone']) && !empty($_POST['phone']) &&
    isset($_POST['password']) && !empty($_POST['password'])
) {
    $username = mysqli_real_escape_string($connection, $_POST['username']);
    $email = mysqli_real_escape_string($connection, $_POST['email']);
    $phone = mysqli_real_escape_string($connection, $_POST['phone']);
    $password = mysqli_real_escape_string($connection, $_POST['password']);
    $status = 'gratis';

    // Meng-hash password sebelum disimpan
    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

    // Periksa apakah username, email, atau nomor telepon sudah digunakan
    $checkQuery = "SELECT * FROM users WHERE username = '$username' OR email = '$email' OR phone = '$phone'";
    $checkResult = mysqli_query($connection, $checkQuery);

    if (mysqli_num_rows($checkResult) > 0) {
        $existingData = mysqli_fetch_assoc($checkResult);

        if ($existingData['username'] == $username) {
            echo json_encode([
                'status' => 'error',
                'message' => 'Username already taken. Please choose a different username.',
            ]);
        } elseif ($existingData['email'] == $email) {
            echo json_encode([
                'status' => 'error',
                'message' => 'Email already registered. Please use a different email.',
            ]);
        } elseif ($existingData['phone'] == $phone) {
            echo json_encode([
                'status' => 'error',
                'message' => 'Phone number already registered. Please use a different phone number.',
            ]);
        }
        exit;
    }

    // Jika tidak ada duplikasi, masukkan data ke database
    $query = "INSERT INTO users (phone, username, email, password, status) VALUES ('$phone', '$username', '$email', '$hashedPassword', '$status')";
    $result = mysqli_query($connection, $query);

    if ($result) {
        // Membuat tabel baru untuk tugas berdasarkan username dengan kolom baru
        $taskTableQuery = "CREATE TABLE tasks_$username (
            id INT AUTO_INCREMENT PRIMARY KEY,
            judul_task VARCHAR(255) NOT NULL,
            description TEXT NOT NULL,
            deadline DATETIME NOT NULL,
            reminder_1_day TINYINT(1) DEFAULT 0, -- Status pengingat 1 hari
            reminder_12_hours TINYINT(1) DEFAULT 0, -- Status pengingat 12 jam
            reminder_1_hour TINYINT(1) DEFAULT 0, -- Status pengingat 1 jam
            reminder_30_minutes TINYINT(1) DEFAULT 0, -- Status pengingat 30 menit
            reminder_15_minutes TINYINT(1) DEFAULT 0, -- Status pengingat 15 menit
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )";
            

        if (mysqli_query($connection, $taskTableQuery)) {
            echo json_encode([
                'status' => 'success',
                'message' => 'User registered and task table created.',
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'User registered, but failed to create task table.',
                'error' => mysqli_error($connection),
            ]);
        }
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to register user!',
            'error' => mysqli_error($connection),
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Invalid input. Please provide all required fields.',
    ]);
}

// Tutup koneksi database
mysqli_close($connection);
?>
