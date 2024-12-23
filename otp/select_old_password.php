<?php
header('Access-Control-Allow-Origin: *'); // Memungkinkan akses dari semua asal
include "config.php"; // Mengimpor file konfigurasi database

$username = $_POST['username']; // Mengambil username dari input POST
$old_password = $_POST['old_password']; // Mengambil old_password dari input POST

// Mengambil data dari database untuk memeriksa password
$query = mysqli_query($connection, "SELECT * FROM registerakun WHERE username='$username' AND psw='$old_password'");

if (mysqli_num_rows($query) > 0) { // Memeriksa apakah ada baris hasil dari query
    echo json_encode(['valid' => true]); // Mengembalikan validasi sukses dalam format JSON
} else {
    echo json_encode(['valid' => false]); // Mengembalikan validasi gagal dalam format JSON
}
?>