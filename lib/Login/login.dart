import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Bottom_nav/bottom_nav.dart';
import '../SignUp/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RegExp _emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final String apiUrl = "https://prakrutitech.xyz/vani/login.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 200) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool("isLoggedIn", true);
          await prefs.setInt("user_id", int.parse(data['user']['id'].toString()));

          await prefs.setString("name", data['user']['name'] ?? '');
          await prefs.setString("email", data['user']['email'] ?? '');
          await prefs.setString("gender", data['user']['gender'] ?? '');

          await prefs.setString("dob", data['user']['date_of_birth'] ?? '');
          await prefs.setString("height", data['user']['height'] ?? '');
          await prefs.setString("weight", data['user']['weight'] ?? '');

          await prefs.setString("fitness_goal", data['user']['fitness_goal'] ?? '');

          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Login successful!")));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNav()),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Invalid credentials")),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error. Please try again.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C75FF), Color(0xFF8E2DE2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: height * 0.02),
                Container(
                  padding: EdgeInsets.all(width * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.orange,
                    size: width * 0.12,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "FitTrack",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Welcome back! Log in to continue",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: width * 0.04,
                  ),
                ),
                SizedBox(height: height * 0.03),
                Container(
                  width: width * 0.88,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.03,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(width * 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _emailController,
                          style: TextStyle(color: Colors.black),
                          decoration: _inputDecoration("Email", Icons.email),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter your email";
                            }
                            if (!_emailRegex.hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: Colors.black),
                          obscureText: _obscurePassword,
                          decoration: _passwordDecoration("Password"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter your password";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.03),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.02,
                              ),
                              backgroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  width * 0.03,
                                ),
                              ),
                            ),
                            onPressed: _isLoading ? null : _loginUser,
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: width * 0.04,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUp(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.04,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: TextStyle(
        color: Colors.red.shade600,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _passwordDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
      suffixIcon: IconButton(
        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade500,),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: TextStyle(
        color: Colors.red.shade600,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}