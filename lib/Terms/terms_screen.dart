import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scale = mq.size.width / 375;

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Terms of Service",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
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
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.description_outlined,
                      color: Colors.white, size: 36 * scale),

                  SizedBox(height: 14 * scale),

                  Text(
                    "Terms of Service",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6 * scale),

                  Text(
                    "Please read these terms carefully before using FitTrack.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14 * scale,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18 * scale),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14 * scale),
              decoration: BoxDecoration(
                color: Color(0xFFE9F1FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Last updated: November 24, 2024",
                style: TextStyle(
                  fontSize: 13 * scale,
                  color: Colors.black87,
                ),
              ),
            ),

            SizedBox(height: 22 * scale),

            _tosCard(
              scale: scale,
              icon: Icons.assignment_turned_in_outlined,
              iconColor: Colors.purpleAccent,
              title: "Acceptance of Terms",
              text:
              "By accessing and using FitTrack, you accept and agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our app.",
            ),

            _tosCard(
              scale: scale,
              icon: Icons.person_outline,
              iconColor: Colors.purpleAccent,
              title: "User Account",
              text:
              "You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.",
            ),

            _tosCard(
              scale: scale,
              icon: Icons.verified_user_outlined,
              iconColor: Colors.purpleAccent,
              title: "Acceptable Use",
              text:
              "You agree to use FitTrack only for lawful purposes and in accordance with these Terms. You may not use the app in any way that could damage, disable, or impair the service.",
            ),

            _tosCard(
              scale: scale,
              icon: Icons.health_and_safety_outlined,
              iconColor: Colors.purpleAccent,
              title: "Health & Safety Disclaimer",
              text:
              "FitTrack provides fitness information and guidance, but is not a substitute for professional medical advice. Always consult with a healthcare professional before starting any fitness program.",
            ),

            _tosCard(
              scale: scale,
              icon: Icons.lightbulb_outline,
              iconColor: Colors.purpleAccent,
              title: "Intellectual Property",
              text:
              "All content, features, and functionality of FitTrack are owned by us and protected by international copyright, trademark, and other intellectual property laws.",
            ),

            _tosCard(
              scale: scale,
              icon: Icons.error_outline,
              iconColor: Colors.purpleAccent,
              title: "Limitation of Liability",
              text:
              "FitTrack shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service.",
            ),

            SizedBox(height: 25 * scale),

            Text(
              "Additional Information",
              style: TextStyle(
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 14 * scale),

            _infoCard(
              scale: scale,
              title: "Changes to Terms",
              text:
              "We reserve the right to modify these terms at any time. We will notify users of any material changes via email or app notification.",
            ),

            _infoCard(
              scale: scale,
              title: "Account Termination",
              text:
              "We reserve the right to terminate or suspend your account if you violate these Terms of Service or engage in fraudulent activity.",
            ),

            _infoCard(
              scale: scale,
              title: "Governing Law",
              text:
              "These Terms shall be governed by the laws of the jurisdiction in which FitTrack operates, without regard to conflict of law provisions.",
            ),

            _infoCard(
              scale: scale,
              title: "Questions About Our Terms?",
              text:
              "If you have questions about these Terms of Service, please contact our legal team.\n\nlegal@fittrack.com",
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _tosCard({
    required double scale,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16 * scale),
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22 * scale),
          ),

          SizedBox(width: 14 * scale),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 13 * scale,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required double scale,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16 * scale),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            text,
            style: TextStyle(
              fontSize: 13 * scale,
              height: 1.4,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}