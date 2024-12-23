<?php
header('Access-Control-Allow-Origin: *'); // Mengatur header untuk mengizinkan permintaan dari semua domain (CORS).

include "config.php"; // Mengimpor file konfigurasi yang berisi pengaturan koneksi ke database.

$username = $_POST['username']; // Mengambil nilai dari input form yang dikirim melalui metode POST dengan nama 'username'.
$email = $_POST['email']; // Mengambil nilai dari input form yang dikirim melalui metode POST dengan nama 'email'.
$phone = $_POST['phone'];
$psw = $_POST['psw']; // Mengambil nilai dari input form yang dikirim melalui metode POST dengan nama 'psw'.

$result = mysqli_query($connection, "INSERT INTO akun (username, email, phone, psw) VALUES ('$username', '$email', '$phone','$psw')"); // Melakukan query untuk memasukkan data baru ke tabel 'registerakun'.

if ($result) { // Memeriksa apakah query berhasil dijalankan
    echo json_encode([ // Mengubah array PHP menjadi format JSON untuk respons
        'message' => 'Data Berhasil di Create' // Pesan sukses jika data berhasil disimpan
    ]);
} else {
    echo json_encode([ // Mengubah array PHP menjadi format JSON untuk respons
        'message' => 'Data Gagal di Create!!!' // Pesan gagal jika data tidak berhasil disimpan
    ]);
}
?>
