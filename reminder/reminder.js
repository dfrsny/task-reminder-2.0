const mysql = require('mysql2');
const axios = require('axios');

// Konfigurasi koneksi database
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'db_otp',
});

const reminderLoop = async () => {
  try {
    const currentTime = Math.floor(Date.now() / 1000); // Waktu sekarang dalam detik

    // Ambil semua pengguna untuk memeriksa tabel tugas mereka
    const [users] = await connection.promise().query("SELECT username, phone FROM users");

    for (const user of users) {
      const username = user.username;
      const phone = user.phone;
      const taskTable = `tasks_${username}`; // Nama tabel tugas untuk pengguna ini

      // Cek apakah tabel tugas pengguna ada
      const [checkTable] = await connection
        .promise()
        .query(`SHOW TABLES LIKE ?`, [taskTable]);

      if (checkTable.length > 0) {
        // Ambil tugas yang belum dikirim pengingat
        const [tasks] = await connection.promise().query(
            `SELECT * FROM ?? WHERE UNIX_TIMESTAMP(deadline) > ?`,
            [taskTable, currentTime]
          );          

        for (const task of tasks) {
          const judulTask = task.judul_task;
          const deadline = task.deadline;

          // Hitung waktu yang tersisa
          const timeDiff = Math.floor(new Date(deadline).getTime() / 1000) - currentTime;

          // Kirim pengingat berdasarkan waktu tersisa
          let message = null;
          let reminderType = null;

          if (timeDiff === 86400 && task.reminder_1_day !== 1) { // Kurang dari 1 hari
            message = `Halo ${username} kamu ada task \"${judulTask}\" yang akan jatuh tempo dalam kurang dari 1 hari🙂.`;
            reminderType = 'reminder_1_day';
          } else if (timeDiff === 43200 && task.reminder_12_hours !== 1) { // Kurang dari 12 jam
            message = `Halo ${username} mau ngingetin lagi, ada task \"${judulTask}\" kurang dari 12 jam, jangan lupa ya😁`;
            reminderType = 'reminder_12_hours';
          } else if (timeDiff === 3600 && task.reminder_1_hour !== 1) { // Kurang dari 1 jam
            message = `Halo ${username} mau ngingetin lagi nih, task "${judulTask}" kurang 1 jam lagi dari deadline kamu😅`;
            reminderType = 'reminder_1_hour';
          } else if (timeDiff === 1800 && task.reminder_30_minutes !== 1) { // Kurang dari 30 menit
            message = `Halo ${username} kamu gk lupa kan ada task "${judulTask}"? karena kurang 30 menit nih deadline nya🤔`;
            reminderType = 'reminder_30_minutes';
          } else if (timeDiff === 900 && task.reminder_15_minutes !== 1) { // Kurang dari 15 menit
            message = `Halo ${username} sekarang sisa 15 menit nih, jangan lupa ada task "${judulTask}" ya, awas kelupaan dan nggak ngerjain tasknya🤯`;
            reminderType = 'reminder_15_minutes';
          }

          if (message && reminderType) {
            // Kirim pesan
            const data = {
              target: phone,
              message: message,
            };

            try {
              const response = await axios.post('https://api.fonnte.com/send', data, {
                headers: {
                  Authorization: 'irLSAi6bEEF4U1NubKPo',
                  'Content-Type': 'application/x-www-form-urlencoded',
                },
              });

              if (response.data.status === true) {
                // Tandai jenis pengingat yang sudah dikirim
                await connection.promise().query(
                  `UPDATE ?? SET ?? = 1 WHERE id = ?`,
                  [taskTable, reminderType, task.id]
                );
              }
            } catch (err) {
              console.error(`Error sending reminder for task ID ${task.id}:`, err.message);
            }
          }
        }
      }
    }

    console.log('Reminder tasks processed successfully.');
  } catch (err) {
    console.error('Error in reminder loop:', err.message);
  }
};

// Jalankan loop setiap detik
setInterval(reminderLoop, 1000);
