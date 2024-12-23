<?php
header('Access-Control-Allow-Origin: *'); // Mengatur header untuk mengizinkan permintaan dari semua domain (CORS).

include "config.php"; // Mengimpor file konfigurasi yang berisi pengaturan koneksi ke database.

if (mysqli_connect_errno()) {
    echo json_encode(['success' => false, 'message' => 'Failed to connect to the database']);
    exit();
}

// Mengambil nilai dari input form yang dikirim melalui metode POST.
$username_or_email = $_POST['username_or_email'];

// Melakukan query untuk memeriksa keberadaan username/email di tabel 'akun'.
$query = "SELECT * FROM users WHERE username='$username_or_email' OR email='$username_or_email'";
$result = mysqli_query($connection, $query);

if (!$result) {
    echo json_encode(['success' => false, 'message' => 'Database query failed: ' . mysqli_error($connection)]);
    exit();
}

if (mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);
    echo json_encode([
        'success' => true,
        'message' => 'Username or email found!',
        'phone' => $row['phone'], // Mengirimkan nomor telepon
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'User not found'
    ]);
}

mysqli_close($connection);
?>
