import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          "Privacy Policy",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                  Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 36 * scale,
                  ),

                  SizedBox(height: 14 * scale),

                  Text(
                    "Your Privacy Matters",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6 * scale),

                  Text(
                    "We are committed to protecting your personal information and being transparent about how we use it.",
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
                "Last updated: November 24, 2025",
                style: TextStyle(fontSize: 13 * scale, color: Colors.black87),
              ),
            ),

            SizedBox(height: 22 * scale),

            _infoCard(
              scale: scale,
              icon: Icons.folder_open_outlined,
              iconColor: Colors.blueAccent,
              title: "Data Collection",
              text:
                  "We collect information you provide directly to us, such as your name, email, fitness goals, and workout data. This helps us personalize your experience and track your progress.",
            ),

            _infoCard(
              scale: scale,
              icon: Icons.lock_outline,
              iconColor: Colors.blueAccent,
              title: "Data Security",
              text:
                  "We use industry-standard encryption and security measures to protect your personal information. Your data is stored securely and is never sold to third parties.",
            ),

            _infoCard(
              scale: scale,
              icon: Icons.info_outline,
              iconColor: Colors.blueAccent,
              title: "How We Use Your Data",
              text:
                  "Your data is used to provide personalized workout recommendations, track your progress, and improve our services. We may also use it to send you notifications about new features and content.",
            ),

            _infoCard(
              scale: scale,
              icon: Icons.notifications_none,
              iconColor: Colors.blueAccent,
              title: "Notifications",
              text:
                  "We may send you push notifications and emails about your workouts, achievements, and app updates. You can manage your notification preferences in the settings.",
            ),

            _infoCard(
              scale: scale,
              icon: Icons.verified_user_outlined,
              iconColor: Colors.blueAccent,
              title: "Your Rights",
              text:
                  "You have the right to access, modify, or delete your personal data at any time. You can also request a copy of all data we have collected about you.",
            ),

            _infoCard(
              scale: scale,
              icon: Icons.cloud_outlined,
              iconColor: Colors.blueAccent,
              title: "Third-Party Services",
              text:
                  "We may use third-party services for analytics and crash reporting. These services are bound by their own privacy policies and do not have access to your personal workout data.",
            ),

            SizedBox(height: 20 * scale),

            _infoCard(
              scale: scale,
              icon: Icons.question_answer_outlined,
              iconColor: Colors.blueAccent,
              title: "Questions About Privacy?",
              text:
                  "If you have any questions about our privacy practices or want to exercise your data rights, please contact us at:\n\nprivacy@fittrack.com",
            ),

            _infoCard(
              scale: scale,
              icon: Icons.check_circle_outline,
              iconColor: Colors.blueAccent,
              title: "Compliance",
              text:
                  "FitTrack is compliant with GDPR, CCPA, and other major privacy regulations. We respect your data rights and provide tools to manage your information.",
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required double scale,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String text,
  }) {
    return Container(
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
}