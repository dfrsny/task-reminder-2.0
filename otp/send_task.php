<?php
header('Access-Control-Allow-Origin: *'); // Mengizinkan akses dari semua origin
header('Content-Type: application/json'); // Format respons JSON
include 'config.php'; // Koneksi ke database

// Pastikan input tersedia
$username = mysqli_real_escape_string($connection, $_POST['username'] ?? '');
$nomor = mysqli_real_escape_string($connection, $_POST['nomor'] ?? '');
$task_title = mysqli_real_escape_string($connection, $_POST['judul_task'] ?? '');
$description = mysqli_real_escape_string($connection, $_POST['description'] ?? '');
$deadline = mysqli_real_escape_string($connection, $_POST['deadline'] ?? '');

if (!$username || !$nomor || !$task_title || !$deadline) {
    echo json_encode(["error" => "All fields are required."]);
    exit;
}

// Pesan yang akan dikirimkan
$message = "Halo $username, kamu mempunyai task yang harus dikerjakan, berikut rincian task kamu:\n\nJudul Task      : $task_title \nDeskripsi Task: $description \nDeadline          : $deadline.\n\nJangan Lupa Task Kamu ya $username 😎";


// Data untuk API Fonnte
$data = [
    'target' => $nomor,
    'message' => $message,
];

// Konfigurasi cURL untuk mengirim pesan
$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.fonnte.com/send",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_CUSTOMREQUEST => "POST",
    CURLOPT_POSTFIELDS => http_build_query($data),
    CURLOPT_HTTPHEADER => [
        'Authorization: irLSAi6bEEF4U1NubKPo', // Ganti dengan API Key Fonnte
        'Content-Type: application/x-www-form-urlencoded'
    ],
    CURLOPT_SSL_VERIFYHOST => 0,
    CURLOPT_SSL_VERIFYPEER => 0,
]);

$result = curl_exec($curl);
$error = curl_error($curl);
curl_close($curl);

if ($error) {
    echo json_encode(["error" => "cURL Error: $error"]);
    exit;
}

// Tanggapan API
$response = json_decode($result, true);
if (isset($response['status']) && $response['status'] == true) {
    echo json_encode(["success" => "Task details successfully sent to WhatsApp."]);
} else {
    echo json_encode(["error" => "Failed to send message: " . ($response['reason'] ?? 'Unknown error')]);
}
?>
