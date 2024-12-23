<?php
date_default_timezone_set('Asia/Jakarta');

    $namaserver = "localhost"; // Mendeklarasikan variabel $namaserver dengan nilai "localhost", yang merupakan alamat server database.
    $userdb = "root"; // Mendeklarasikan variabel $userdb dengan nilai "root", yang merupakan username untuk mengakses database.
    $passdb = ""; // Mendeklarasikan variabel $passdb dengan nilai kosong, yang merupakan password untuk mengakses database.
    $namadb = "db_otp"; // Mendeklarasikan variabel $namadb dengan nama database yang akan diakses, yaitu "flutterapi".
    $connection = mysqli_connect($namaserver, $userdb, $passdb, $namadb); // Membuat koneksi ke database menggunakan fungsi mysqli_connect dengan parameter server, username, password, dan nama database.

    if (!$connection){ // Memeriksa apakah koneksi gagal
        die("Koneksi ke server gagal!".mysqli_connect_error()); // Jika koneksi gagal, menghentikan eksekusi dan menampilkan pesan kesalahan.
    }
?>



