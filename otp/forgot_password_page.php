<?php
header('Access-Control-Allow-Origin: *'); // Memungkinkan akses dari semua asal
include "config.php"; // Mengimpor file konfigurasi database

$username = $_POST['username']; // Mengambil username dari input form
$email = $_POST['email']; // Mengambil email dari input form

// Memeriksa apakah akun dengan username dan email ada
$result = mysqli_query($connection, "SELECT psw FROM registerakun WHERE username='$username' AND email='$email'");

if (mysqli_num_rows($result) > 0) { // Memeriksa apakah ada hasil
    $row = mysqli_fetch_assoc($result); // Mengambil data pengguna
    echo json_encode([ // Mengubah array PHP menjadi format JSON
        'message' => 'Akun ditemukan', // Pesan sukses
        'password' => $row['psw'] // Mengembalikan password dalam bentuk plaintext
    ]);
} else {
    echo json_encode([ // Mengubah array PHP menjadi format JSON
        'message' => 'Akun tidak ditemukan' // Pesan kesalahan
    ]);
}
?>