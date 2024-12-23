<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
date_default_timezone_set('Asia/Jakarta');

    $namaserver = "localhost"; // Mendeklarasikan variabel $namaserver dengan nilai "localhost", yang merupakan alamat server database.
    $userdb = "root"; // Mendeklarasikan variabel $userdb dengan nilai "root", yang merupakan username untuk mengakses database.
    $passdb = ""; // Mendeklarasikan variabel $passdb dengan nilai kosong, yang merupakan password untuk mengakses database.
    $namadb = "db_otp"; // Mendeklarasikan variabel $namadb dengan nama database yang akan diakses, yaitu "flutterapi".
    $connection = mysqli_connect($namaserver, $userdb, $passdb, $namadb); // Membuat koneksi ke database menggunakan fungsi mysqli_connect dengan parameter server, username, password, dan nama database.

    if (!$connection){ // Memeriksa apakah koneksi gagal
        die("Koneksi ke server gagal!".mysqli_connect_error()); // Jika koneksi gagal, menghentikan eksekusi dan menampilkan pesan kesalahan.
    }

$current_time = time(); // Waktu sekarang

// Ambil semua pengguna untuk memeriksa tabel tugas mereka
$user_query = "SELECT username, phone FROM users";
$user_result = mysqli_query($connection, $user_query);

if (mysqli_num_rows($user_result) > 0) {
    while ($user = mysqli_fetch_assoc($user_result)) {
        $username = $user['username'];
        $phone = $user['phone'];
        $task_table = "tasks_" . $username; // Nama tabel tugas untuk pengguna ini

        // Cek apakah tabel tugas pengguna ada
        $check_table_query = "SHOW TABLES LIKE '$task_table'";
        $check_table_result = mysqli_query($connection, $check_table_query);

        if (mysqli_num_rows($check_table_result) > 0) {
            // Ambil tugas dengan tenggat waktu kurang dari 24 jam dan belum dikirim pengingat
            $task_query = "
                SELECT * 
                FROM $task_table
                WHERE status_reminder = 0 
                  AND UNIX_TIMESTAMP(deadline) - $current_time BETWEEN 0 AND 86400";

            $task_result = mysqli_query($connection, $task_query);

            if (mysqli_num_rows($task_result) > 0) {
                while ($task = mysqli_fetch_assoc($task_result)) {
                    $judul_task = $task['judul_task'];
                    $deadline = $task['deadline'];

                    // Hitung waktu yang tersisa
                    $time_diff = strtotime($deadline) - $current_time;
                    $hours = floor($time_diff / 3600);
                    $minutes = floor(($time_diff % 3600) / 60);

                    $message = "Reminder: Task \"$judul_task\" akan jatuh tempo dalam $hours jam dan $minutes menit.";

                    // Kirim pesan
                    $data = [
                        'target' => $phone,
                        'message' => $message,
                    ];

                    $curl = curl_init();
                    curl_setopt_array($curl, [
                        CURLOPT_URL => "https://api.fonnte.com/send",
                        CURLOPT_RETURNTRANSFER => true,
                        CURLOPT_CUSTOMREQUEST => "POST",
                        CURLOPT_POSTFIELDS => http_build_query($data),
                        CURLOPT_HTTPHEADER => [
                            'Authorization: irLSAi6bEEF4U1NubKPo',
                            'Content-Type: application/x-www-form-urlencoded'
                        ],
                    ]);

                    $result = curl_exec($curl);
                    $error = curl_error($curl);
                    curl_close($curl);

                    if ($error) {
                        echo json_encode(["error" => "cURL Error: $error"]);
                    } else {
                        $response = json_decode($result, true);
                        if ($response['status'] == true) {
                            // Tandai tugas sebagai sudah diingatkan
                            $update_query = "UPDATE $task_table SET status_reminder = 1 WHERE id = {$task['id']}";
                            mysqli_query($connection, $update_query);
                        }
                    }
                }
            }
        }
    }
}

echo json_encode(["status" => "Reminder tasks processed successfully."]);
?>
