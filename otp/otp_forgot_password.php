<?php
header('Access-Control-Allow-Origin: *'); // Mengizinkan akses dari semua origin
header('Content-Type: application/json'); // Mengatur tipe konten sebagai JSON
include 'config.php'; // Include file konfigurasi koneksi database

// Fungsi untuk menangani pengiriman OTP
if (isset($_POST['submit-otp'])) {
    $nomor = mysqli_real_escape_string($connection, $_POST['nomor']); // Membersihkan input nomor untuk keamanan

    if ($nomor) {
        // Hapus OTP sebelumnya untuk nomor yang sama
        if (!mysqli_query($connection, "DELETE FROM otp_device WHERE nomor = '$nomor'")) {
            echo json_encode(["error" => "Error: " . mysqli_error($connection)]); // Kirim error sebagai JSON
            exit;
        }

        // Generate OTP baru
        $otp = rand(100000, 999999);
        $waktu = time();

        // Masukkan OTP ke database
        if (!mysqli_query($connection, "INSERT INTO otp_device (nomor, otp, waktu) VALUES ('$nomor', '$otp', '$waktu')")) {
            echo json_encode(["error" => "Error: " . mysqli_error($connection)]);
            exit;
        }

        // Data yang akan dikirim ke API
        $data = [
            'target' => $nomor,
            'message' => "Your OTP: " . $otp,
        ];

        // Inisialisasi cURL
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL => "https://api.fonnte.com/send",
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CUSTOMREQUEST => "POST",
            CURLOPT_POSTFIELDS => http_build_query($data), // Kirim data dalam format URL-encoded
            CURLOPT_HTTPHEADER => [
                'Authorization: irLSAi6bEEF4U1NubKPo', // Pastikan token API valid
                'Content-Type: application/x-www-form-urlencoded' // Jenis konten sesuai dengan data POST
            ],
            CURLOPT_SSL_VERIFYHOST => 0, // Nonaktifkan verifikasi SSL (jika diperlukan)
            CURLOPT_SSL_VERIFYPEER => 0,
        ]);

        // Eksekusi cURL dan tangkap hasilnya
        $result = curl_exec($curl);
        $error = curl_error($curl);
        curl_close($curl);

        // Penanganan respons dari API
        if ($error) {
            echo json_encode(["error" => "cURL Error: " . $error]); // Kirim error cURL sebagai JSON
            exit;
        }

        $response = json_decode($result, true); // Decode respons API
        if (isset($response['status']) && $response['status'] == true) {
            echo json_encode(["success" => "OTP berhasil dikirim ke WhatsApp."]);
        } else {
            echo json_encode(["error" => "Gagal mengirim OTP: " . ($response['reason'] ?? 'Unknown error')]);
        }
    } else {
        echo json_encode(["error" => "Nomor tidak valid."]);
    }
}
// Fungsi untuk menangani login dengan OTP
elseif (isset($_POST['submit-login'])) {
    $otp = mysqli_real_escape_string($connection, $_POST['otp']); // Membersihkan input OTP untuk keamanan
    $nomor = mysqli_real_escape_string($connection, $_POST['nomor']); // Membersihkan input nomor untuk keamanan

    // Validasi OTP
    $q = mysqli_query($connection, "SELECT * FROM otp_device WHERE nomor = '$nomor' AND otp = '$otp'");
    $row = mysqli_num_rows($q);
    $r = mysqli_fetch_array($q);

    if ($row) {
        // Validasi waktu OTP (5 menit)
        if (time() - $r['waktu'] <= 300) {
            echo json_encode(["success" => "OTP benar."]);
        } else {
            echo json_encode(["error" => "OTP expired."]);
        }
    } else {
        echo json_encode(["error" => "OTP salah."]);
    }
} else {
    echo json_encode(["error" => "Invalid request."]);
}
?>
