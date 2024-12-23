import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http; // Untuk mengirim permintaan HTTP
import 'package:login_page_day_23/otp_page_no.dart'; // Mengimpor halaman OTP

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPage createState() => _ForgotPasswordPage();
}

class _ForgotPasswordPage extends State<ForgotPasswordPage> {
  final TextEditingController usernameController = TextEditingController();
  String? nomor; // Variabel untuk menyimpan nomor telepon

  Future<void> login() async {
    final String apiUrl = "http://localhost/otp/check_username.php";

    final Map<String, String> body = {
      "username_or_email": usernameController.text,
    };

    try {
      final response = await http.post(Uri.parse(apiUrl), body: body);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          if (data['success'] == true) {
            nomor = data['phone'];

            if (nomor != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OtpSelectionPage(nomor: nomor!)),
              );
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Error"),
                  content: Text("Nomor telepon tidak ditemukan."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("OK"),
                    ),
                  ],
                ),
              );
            }
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Error"),
                content: Text(data['message'] ?? 'Unknown error'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
            );
          }
        } catch (e) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Error"),
              content: Text("Failed to parse response: $e"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception("Failed to connect to server. Status code: ${response.statusCode}");
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("An error occurred: $e"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FadeInUp(
                          duration: Duration(milliseconds: 1000),
                          child: Text(
                            "Forgot Password",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 20),
                        FadeInUp(
                          duration: Duration(milliseconds: 1200),
                          child: Text(
                            "Masukkan Username atau email Akun Anda",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700]),
                          ),
                        ),
                        FadeInUp(
                          duration: Duration(milliseconds: 1200),
                          child: makeInput(
                            controller: usernameController,
                            label: "Username/Email",
                          ),
                        ),
                      ],
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 1400),
                      child: Container(
                        padding: EdgeInsets.only(top: 3, left: 3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.black)),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          height: 60,
                          onPressed: login,
                          color: Colors.greenAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget makeInput({String? label, TextEditingController? controller, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label!,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}

class OtpSelectionPage extends StatelessWidget {
  final String nomor;

  OtpSelectionPage({required this.nomor});

  Future<void> sendOtpViaPhone(BuildContext context, String nomor) async {
    final response = await http.post(
      Uri.parse('http://localhost/otp/otp_forgot_password.php'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: <String, String>{
        'nomor': nomor,
        'submit-otp': '1',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP telah dikirim ke nomor telepon!')),
      );

      // Arahkan ke halaman OTP
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPPageNo(nomor: nomor)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim OTP, coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select OTP Method"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "How do you want to receive your OTP?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.email),
              title: Text("Send OTP via Email"),
              onTap: () {
                // Tindakan untuk mengirim OTP melalui email (pindahkan logika ke backend jika perlu)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OTPPageNo(nomor: nomor)),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text("Send OTP via Phone"),
              onTap: () {
                sendOtpViaPhone(context, nomor);  // Panggil fungsi untuk mengirim OTP ke nomor
              },
            ),
          ],
        ),
      ),
    );
  }
}
