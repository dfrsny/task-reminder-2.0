import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import package http untuk melakukan request
import 'package:login_page_day_23/login.dart';
import 'package:login_page_day_23/otp_page_no.dart'; // Mengimpor halaman OTP

class ForgotPasswordPage extends StatefulWidget { // Mengubah ke StatefulWidget
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _phoneController = TextEditingController(); // Controller untuk TextField

  Future<void> _requestOTP() async {
    String nomor = _phoneController.text.trim(); // Mengambil input nomor telepon

    if (nomor.isNotEmpty) {
      // Kirim permintaan ke server Anda
      final response = await http.post(
        Uri.parse('http://localhost/otp/otp_forgot_password.php'), // Ganti dengan URL server Anda
        body: {
          'submit-otp': '1',
          'nomor': nomor,
        },
      );
  
      // Periksa respons dari server
      if (response.statusCode == 200) {
        // Jika permintaan berhasil, navigasikan ke halaman OTP
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OTPPageNo(nomor: nomor)), // Kirim nomor telepon ke halaman OTP
        );
      } else {
        // Tampilkan pesan kesalahan jika ada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim OTP, silakan coba lagi.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nomor telepon tidak boleh kosong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Warna latar belakang putih polos
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding sekitar halaman
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gambar di tengah halaman
              Image.asset(
                'assets/image/otp and payment/forgot_password.png', // Ganti dengan path gambar yang Anda gunakan
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),

              // Text "Forgot Password?"
              const Text(
                'Lupa Password?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Text penjelasan
              const Text(
                'Masukkan nomor telepon Anda, kami akan mengirimkan tautan untuk mengatur ulang password Anda beserta OTP konfirmasi. Terima kasih.',
                textAlign: TextAlign.center, // Mengatur teks agar berada di tengah
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // TextField untuk nomor telepon
              TextField(
                controller: _phoneController, // Menggunakan controller
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(), // Border untuk TextField
                  prefixIcon: const Icon(Icons.phone, color: Colors.grey), // Ikon telepon di sebelah kiri
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Submit
              ElevatedButton(
                onPressed: _requestOTP, // Memanggil fungsi untuk mengirim OTP
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF4F00), // Warna tombol
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50), // Padding tombol
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Teks "Remember your password? Back to Sign In"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ingat Password Anda?'), // Teks
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text(
                      'Back to Sign In',
                      style: TextStyle(
                        color: Colors.blue, // Warna teks untuk Back to Sign In
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
