import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../trainer.dart';

class BecomeTrainerScreen extends StatefulWidget {
  const BecomeTrainerScreen({super.key});

  @override
  State<BecomeTrainerScreen> createState() => _BecomeTrainerScreenState();
}

class _BecomeTrainerScreenState extends State<BecomeTrainerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submitTrainerForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/vani/insert_trainers.php"),
        body: {
          "name": _nameController.text,
          "email": _emailController.text,
          "phone": _phoneController.text,
          "specialty": _specialtyController.text,
          "experience": _experienceController.text,
        },
      );

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Trainer application submitted! Pending approval."),
            ),
          );

          await Future.delayed(Duration(seconds: 2));

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TrainerScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? "Submission failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error. Try again later.")),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Color(0xFFF3F4F6),
      prefixIcon: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.black),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.3),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      backgroundColor: Color(0xFFF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          "Apply as Trainer",
          style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 20 * scale,
          vertical: 20 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Apply as Trainer",
              style: TextStyle(
                fontSize: 24 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              "Join our community of certified trainers",
              style: TextStyle(fontSize: 15 * scale, color: Colors.grey[700]),
            ),

            SizedBox(height: 24 * scale),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),),
                  SizedBox(height: 8 * scale),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(
                      "Enter your full name",
                      Icons.person,
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Enter your full name" : null,
                  ),
                  SizedBox(height: 18 * scale),
                  Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),),
                  SizedBox(height: 8 * scale),
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration(
                      "Enter your email",
                      Icons.email,
                    ),
                    validator: (v) => v!.isEmpty ? "Enter your email" : null,
                  ),
                  SizedBox(height: 18 * scale),
                  Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),),
                  SizedBox(height: 8 * scale),
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration(
                      "Enter your phone number",
                      Icons.phone,
                    ),
                  ),
                  SizedBox(height: 18 * scale),
                  Text("Specialty", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),),
                  SizedBox(height: 8 * scale),
                  TextFormField(
                    controller: _specialtyController,
                    decoration: _inputDecoration(
                      "e.g., Yoga, HIIT, Strength Training",
                      Icons.fitness_center,
                    ),
                  ),
                  SizedBox(height: 18 * scale),
                  Text("Years of Experience", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),),
                  SizedBox(height: 8 * scale),
                  TextFormField(
                    controller: _experienceController,
                    decoration: _inputDecoration(
                      "Enter years of experience",
                      Icons.work,
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: 28 * scale),

                  SizedBox(
                    width: double.infinity,
                    height: 50 * scale,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitTrainerForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Submit Application",
                              style: TextStyle(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30 * scale),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18 * scale),
              decoration: BoxDecoration(
                color: Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What happens next?",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16 * scale,
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  Row(
                    children: [
                      Text("• "),
                      Expanded(
                        child: Text(
                          "We'll review your application within 2-3 business days",
                          style: TextStyle(fontSize: 14 * scale),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: [
                      Text("• "),
                      Expanded(
                        child: Text(
                          "You'll receive an email with next steps",
                          style: TextStyle(fontSize: 14 * scale),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: [
                      Text("• "),
                      Expanded(
                        child: Text(
                          "Background check and certification verification required",
                          style: TextStyle(fontSize: 14 * scale),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}