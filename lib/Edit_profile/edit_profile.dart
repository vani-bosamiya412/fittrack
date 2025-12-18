import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  bool _isLoading = false;
  int? userId;

  List<String> genderOptions = ["Male", "Female"];
  List<String> goalOptions = ["Lose Weight", "Build Muscle", "Stay Fit", "Improve Endurance", "Increase Flexibility"];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    userId = prefs.getInt("user_id");

    setState(() {
      _nameController.text = prefs.getString("name") ?? "";
      _emailController.text = prefs.getString("email") ?? "";
      _genderController.text = _normalizeGender(prefs.getString("gender") ?? "");
      _dobController.text = prefs.getString("dob") ?? "";
      _heightController.text = prefs.getString("height") ?? "";
      _weightController.text = prefs.getString("weight") ?? "";
      _goalController.text = _normalizeGoal(prefs.getString("fitness_goal") ?? "");
    });
  }

  String _normalizeGender(String value) {
    if (value.toLowerCase() == "male") return "Male";
    if (value.toLowerCase() == "female") return "Female";
    return "";
  }

  String _normalizeGoal(String value) {
    for (var option in goalOptions) {
      if (option.toLowerCase() == value.toLowerCase()) {
        return option;
      }
    }
    return "";
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String apiUrl = "https://prakrutitech.xyz/vani/update_user.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "id": userId.toString(),
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "gender": _genderController.text.trim(),
          "dob": _dobController.text.trim(),
          "height": _heightController.text.trim(),
          "weight": _weightController.text.trim(),
          "fitness_goal": _goalController.text.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == "success") {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString("name", _nameController.text.trim());
        await prefs.setString("email", _emailController.text.trim());
        await prefs.setString("gender", _genderController.text.trim());
        await prefs.setString("dob", _dobController.text.trim());
        await prefs.setString("height", _heightController.text.trim());
        await prefs.setString("weight", _weightController.text.trim());

        await prefs.setString("fitness_goal", _goalController.text.trim());

        if (!mounted) return;
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Update failed")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Widget sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: TextStyle(color: Colors.black),
          keyboardType: type,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black,),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (v) =>
              v!.trim().isEmpty ? "This field cannot be empty" : null,
        ),
        SizedBox(height: 14),
      ],
    );
  }

  Widget dobField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date of Birth",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: _dobController,
          readOnly: true,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.calendar_month, color: Colors.black,),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (v) =>
          v!.trim().isEmpty ? "Please select your date of birth" : null,

          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );

            if (pickedDate != null) {
              _dobController.text =
              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            }
          },
        ),
        SizedBox(height: 14),
      ],
    );
  }

  Widget dropdownField({
    required String label,
    required TextEditingController controller,
    required List<String> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<String>(
            value: controller.text.isEmpty ? null : controller.text,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(border: InputBorder.none),
            items: options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              setState(() {
                controller.text = val!;
              });
            },
          ),
        ),
        SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              sectionCard(
                title: "Basic Information",
                children: [
                  inputField(
                    label: "Full Name",
                    controller: _nameController,
                    icon: Icons.person,
                  ),
                  inputField(
                    label: "Email",
                    controller: _emailController,
                    icon: Icons.email,
                  ),
                  dobField(),
                  dropdownField(
                    label: "Gender",
                    controller: _genderController,
                    options: genderOptions,
                  ),
                ],
              ),
              sectionCard(
                title: "Physical Stats",
                children: [
                  inputField(
                    label: "Weight (kg)",
                    controller: _weightController,
                    icon: Icons.monitor_weight,
                    type: TextInputType.number,
                  ),
                  inputField(
                    label: "Height (cm)",
                    controller: _heightController,
                    icon: Icons.height,
                    type: TextInputType.number,
                  ),
                ],
              ),
              sectionCard(
                title: "Fitness Goal",
                children: [
                  dropdownField(
                    label: "Goal",
                    controller: _goalController,
                    options: goalOptions,
                  ),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Save Changes",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}