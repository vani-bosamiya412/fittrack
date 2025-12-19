import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Achievements/my_achievements.dart';
import '../Edit_profile/edit_profile.dart';
import '../Help_and_support/help_and_support_screen.dart';
import '../Notification/app_notification_screen.dart';
import '../Notification/notification_screen.dart';
import '../Privacy/privacy_screen.dart';
import '../Terms/terms_screen.dart';
import '../auth/Login/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  String dob = "";
  String weight = "";
  String height = "";
  String fitnessGoal = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name") ?? "";
      email = prefs.getString("email") ?? "";

      dob = prefs.getString("dob") ?? "";
      weight = prefs.getString("weight") ?? "";
      height = prefs.getString("height") ?? "";
      fitnessGoal = prefs.getString("fitness_goal") ?? "";
    });
  }

  int calculateAge(String dobString) {
    if (dobString.isEmpty) return 0;

    try {
      DateTime dob = DateTime.parse(dobString);
      DateTime today = DateTime.now();

      int age = today.year - dob.year;

      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      return age;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scale = mq.size.width / 375;

    String initials = name.isNotEmpty ? name[0].toUpperCase() : "?";

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: Color(0xFFA353FF),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20 * scale),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 38 * scale,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 32 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 16 * scale),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              email,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14 * scale,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * scale),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * scale,
                        vertical: 10 * scale,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.40),
                            Colors.white.withValues(alpha: 0.20),
                          ],
                        ),
                      ),
                      child: Text(
                        "Fitness Goal\n${fitnessGoal.isEmpty ? 'Not Set' : fitnessGoal}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * scale,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20 * scale),
              Row(
                children: [
                  _statBox("Age", dob.isEmpty ? "--" : "${calculateAge(dob)} years", scale),
                  _statBox("Weight", weight.isEmpty ? "--" : "$weight kg", scale),
                  _statBox("Height", height.isEmpty ? "--" : "$height cm", scale),
                ],
              ),
              SizedBox(height: 25 * scale),
              Text(
                "Account",
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10 * scale,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10 * scale,),
                    _settingsTile(
                      icon: Icons.edit,
                      title: "Edit Profile",
                      scale: scale,
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(),
                          ),
                        );
                        if (updated == true) {
                          _loadUserData();
                        }
                      },
                    ),
                    SizedBox(height: 10 * scale,),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 10 * scale,),
                    _settingsTile(
                      icon: Icons.star_border,
                      title: "My Achievements",
                      scale: scale,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyAchievementsScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 10 * scale,),
                  ],
                ),
              ),
              SizedBox(height: 25 * scale),
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10 * scale,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10 * scale),
                    _settingsTile(
                      icon: Icons.notifications,
                      title: "Notification Settings",
                      scale: scale,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 10 * scale),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 10 * scale),
                    _settingsTile(
                      icon: Icons.settings,
                      title: "App Settings",
                      scale: scale,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AppSettingsScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 10 * scale),
                  ],
                ),
              ),
        
              SizedBox(height: 25 * scale),
              Text(
                "Support & Legal",
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10 * scale,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10 * scale),
                    _settingsTile(
                      icon: Icons.headset_mic_outlined,
                      title: "Help & Support",
                      scale: scale,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HelpSupportScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 10 * scale),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 10 * scale),
                    _settingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      scale: scale,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 10 * scale),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 10 * scale),
                    _settingsTile(
                      icon: Icons.info_outline,
                      title: "Terms of Service",
                      scale: scale,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TermsOfServiceScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 10 * scale),
                  ],
                ),
              ),
              SizedBox(height: 25 * scale),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    int? totalWorkoutMinutes = prefs.getInt('totalWorkoutMinutes');
        
                    await prefs.remove("isLoggedIn");
                    await prefs.remove("user_id");
        
                    if (totalWorkoutMinutes != null) {
                      await prefs.setInt(
                        'totalWorkoutMinutes',
                        totalWorkoutMinutes,
                      );
                    }
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                          (route) => false,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16 * scale),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE6E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 6),
                          Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
  }

  Widget _statBox(String title, String value, double scale) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6 * scale),
        padding: EdgeInsets.symmetric(vertical: 16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14 * scale,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required double scale,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.black, size: 22 * scale),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 18 * scale,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}