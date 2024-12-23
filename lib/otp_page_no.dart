import 'dart:async';
import 'dart:convert'; // Tambahkan untuk decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page_day_23/ubahPasswordPage.dart';

class OTPPageNo extends StatefulWidget {
  final String nomor;

  const OTPPageNo({super.key, required this.nomor});

  @override
  State<OTPPageNo> createState() => _OTPPageStateNo();
}

class _OTPPageStateNo extends State<OTPPageNo> {
  int _start = 30;
  Timer? _timer;
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  String _otp = '';

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _start = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start > 0) {
        setState(() {
          _start--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> resendOTP() async {
    startTimer();
    print('OTP dikirim ulang ke ${widget.nomor}');

    final response = await http.post(
      Uri.parse('http://localhost/otp/otp_forgot_password.php'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: <String, String>{
        'nomor': widget.nomor,
        'submit-otp': '1', // Menandakan permintaan OTP baru
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP telah dikirim ulang!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim OTP, coba lagi.')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1) {
      _otp += value;
      if (index < _controllers.length - 1) {
        FocusScope.of(context).nextFocus();
      }
    } else if (value.isEmpty && index > 0) {
      _otp = _otp.substring(0, _otp.length - 1);
      FocusScope.of(context).previousFocus();
    }
  }

  void _verifyOTP() async {
    if (_otp.length == 6) {
      print('OTP yang dimasukkan: $_otp');

      try {
        final response = await http.post(
          Uri.parse('http://localhost/otp/otp_forgot_password.php'),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: <String, String>{
            'otp': _otp.trim(),
            'nomor': widget.nomor,
            'submit-login': '1',
          },
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body); // Parse JSON respons
          print('Response from server: $responseBody');

          if (responseBody['success'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP berhasil diverifikasi!')),
            );

            // Navigasi ke halaman ubah password
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChangePasswordPage(nomor: widget.nomor),
              ),
            );
          } else if (responseBody['error'] == 'OTP expired.') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP telah kedaluwarsa.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('OTP tidak valid, silakan coba lagi.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Gagal menghubungi server, coba lagi.')),
          );
        }
      } catch (e) {
        print('Error during OTP verification: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Terjadi kesalahan saat verifikasi, coba lagi.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP tidak valid, silakan coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/image/otp and payment/waiting.png',
                height: 200),
            const SizedBox(height: 20),
            const Text(
              'Masukkan OTP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Kode OTP telah dikirim ke nomor Anda melalui WhatsApp. Masukkan kode untuk melanjutkan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Nomor Telepon: +${widget.nomor}',
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _controllers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => _onChanged(value, index),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Kirim ulang kode dalam "),
                Text(
                  _start > 0 ? "00:${_start.toString().padLeft(2, '0')}" : "",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                if (_start == 0)
                  TextButton(
                    onPressed: resendOTP,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                    child: const Text('Kirim Ulang'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              ),
              child: const Text('Verifikasi',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('Kembali', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
