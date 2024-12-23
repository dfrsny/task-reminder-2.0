const cron = require('node-cron');
const { exec } = require('php-shell');

// Menjadwalkan pengingat setiap 5 menit
cron.schedule('*/5 * * * *', () => {
  console.log('Menjalankan pengingat tugas...');

  // Jalankan file PHP dengan PHP CLI
  exec('php C:/path/to/your/task_reminder.php', (error, stdout, stderr) => {
    if (error) {
      console.error(`Error saat menjalankan skrip PHP: ${error}`);
      return;
    }
    if (stderr) {
      console.error(`stderr: ${stderr}`);
      return;
    }
    console.log(`stdout: ${stdout}`);
  });
});

console.log('Task reminder scheduler telah dimulai!');
