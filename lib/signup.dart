import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'package:login_page_day_23/login.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? emailError, usernameError, phoneError, passwordError, confirmPasswordError;

  bool _validateInputs() {
    setState(() {
      usernameError = usernameController.text.isEmpty ? "Username tidak boleh kosong" : null;
      emailError = emailController.text.isEmpty ? "Email tidak boleh kosong" : null;
      phoneError = phoneController.text.isEmpty ? "Nomor telepon tidak boleh kosong" : null;
      passwordError = passwordController.text.isEmpty ? "Password tidak boleh kosong" : null;
      confirmPasswordError = confirmPasswordController.text != passwordController.text
          ? "Konfirmasi password harus sama dengan password"
          : null;
    });

    return usernameError == null &&
        emailError == null &&
        phoneError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  Future<void> registerUser(BuildContext context) async {
    if (!_validateInputs()) return;

    final url = Uri.parse("http://localhost/otp/register_akun.php");
    try {
      final response = await http.post(
        url,
        body: {
          'username': usernameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );

        if (responseData['status'] == 'success') {
          // Navigasi ke halaman login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(), // Ganti ke halaman Login
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.reasonPhrase}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $error")),
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
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: const Text(
                            "Sign up",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1200),
                          child: Text(
                            "Create an account, It's free",
                            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FadeInUp(
                          duration: const Duration(milliseconds: 1200),
                          child: makeInput(
                            label: "Username",
                            controller: usernameController,
                            errorText: usernameError,
                          ),
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1200),
                          child: makeInput(
                            label: "Email",
                            controller: emailController,
                            errorText: emailError,
                          ),
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1200),
                          child: makeInput(
                            label: "Phone",
                            controller: phoneController,
                            errorText: phoneError,
                          ),
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1300),
                          child: makeInput(
                            label: "Password",
                            controller: passwordController,
                            obscureText: true,
                            errorText: passwordError,
                          ),
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1400),
                          child: makeInput(
                            label: "Confirm Password",
                            controller: confirmPasswordController,
                            obscureText: true,
                            errorText: confirmPasswordError,
                          ),
                        ),
                      ],
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: Container(
                        padding: const EdgeInsets.only(top: 3, left: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.black),
                        ),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          height: 60,
                          onPressed: () => registerUser(context),
                          color: Colors.greenAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Text(
                            "Sign up",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget makeInput({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            errorText: errorText,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
