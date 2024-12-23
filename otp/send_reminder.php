<?php
include 'config.php';

$currentTime = time();
$tasks = mysqli_query($connection, "SELECT * FROM tasks");

while ($task = mysqli_fetch_assoc($tasks)) {
    $deadline = strtotime($task['deadline']);
    $timeDiff = $deadline - $currentTime;

    if ($timeDiff > 0 && ($timeDiff <= 900 || $timeDiff <= 1800)) {
        $nomor = $task['nomor'];
        $message = "Pengingat Task: {$task['description']} akan berakhir pada {$task['deadline']}";

        $data = ['target' => $nomor, 'message' => $message];
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL => "https://api.fonnte.com/send",
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POSTFIELDS => http_build_query($data),
            CURLOPT_HTTPHEADER => ['Authorization: irLSAi6bEEF4U1NubKPo']
        ]);

        $result = curl_exec($curl);
        curl_close($curl);
    }
}
?>
