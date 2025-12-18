import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Login/login.dart';

class SignUp extends StatefulWidget {
  final String? gender;
  final DateTime? dob;
  final double? height;
  final double? weight;

  const SignUp({super.key, this.gender, this.dob, this.height, this.weight});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final RegExp _nameRegex = RegExp(r'^[A-Za-z ]{3,}$');
  final RegExp _emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

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
                  "Start your transformation today",
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
                          "Create Account",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            "Full Name",
                            Icons.person,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter your name";
                            }
                            if (!_nameRegex.hasMatch(value)) {
                              return "At least 3 letters, alphabets only";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _emailController,
                          style: TextStyle(
                            color: Colors.black,
                          ),
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
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          obscureText: _obscurePassword,
                          decoration: _passwordDecoration("Password"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter a password";
                            }
                            if (!_passwordRegex.hasMatch(value)) {
                              return "Min 8 chars (A-Z, a-z, 0-9, special)";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _confirmPasswordController,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          obscureText: _obscurePassword,
                          decoration: _passwordDecoration("Confirm Password"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Confirm your password";
                            }
                            if (value != _passwordController.text) {
                              return "Passwords don’t match";
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
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      await _insertUsers();
                                    }
                                  },
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    "Sign Up",
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
                            Text("Already have an account?", style: TextStyle(color: Colors.black, fontSize: width * 0.04),),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Login",
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
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
      ),
      prefixIcon: Icon(icon, color: Colors.grey.shade600,),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: TextStyle(
        color: Colors.red.shade600,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      )
    );
  }

  InputDecoration _passwordDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
      ),
      prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600,),
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
      )
    );
  }

  Future<void> _insertUsers() async {
    final String apiUrl = "https://prakrutitech.xyz/vani/insert_user.php";

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'gender': widget.gender ?? '',
          'dob': widget.dob != null
              ? "${widget.dob!.year}-${widget.dob!.month.toString().padLeft(2, '0')}-${widget.dob!.day.toString().padLeft(2, '0')}"
              : '',
          'height': widget.height?.toString() ?? '',
          'weight': widget.weight?.toString() ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Account created successfully! Please log in."),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          if(!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Error creating account"),
            ),
          );
        }
      } else {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error. Try again later.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}