import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trainer;

  const TrainerDetailScreen({super.key, required this.trainer});

  Future<void> _launchDialer(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Widget buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(14 * scale),
      margin: EdgeInsets.only(bottom: 14 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Icon(icon, color: color, size: 22 * scale),
          ),
          SizedBox(width: 16 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13 * scale,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                value.isEmpty ? "-" : value,
                style: TextStyle(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      backgroundColor: Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          "Trainer Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 110 * scale,
                    height: 110 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4C3AFF), Color(0xFFA353FF),],
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 55,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    trainer['name'] ?? '',
                    style: TextStyle(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale,
                      vertical: 6 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trainer['specialty'] ?? "",
                      style: TextStyle(
                        fontSize: 13 * scale,
                        color: Color(0xFF673AB7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24 * scale),
            Text(
              "Contact Information",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18 * scale,
              ),
            ),
            SizedBox(height: 16 * scale),
            buildInfoBox(
              icon: Icons.email_rounded,
              title: "Email",
              value: trainer['email'] ?? "",
              color: Colors.blue,
              scale: scale,
            ),
            buildInfoBox(
              icon: Icons.phone_rounded,
              title: "Phone",
              value: trainer['phone'] ?? "",
              color: Colors.green,
              scale: scale,
            ),
            SizedBox(height: 24 * scale),
            Text(
              "Professional Details",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18 * scale,
              ),
            ),
            SizedBox(height: 16 * scale),
            buildInfoBox(
              icon: Icons.star_rounded,
              title: "Specialty",
              value: trainer['specialty'] ?? "",
              color: Colors.purple,
              scale: scale,
            ),
            buildInfoBox(
              icon: Icons.timelapse_rounded,
              title: "Experience",
              value: "${trainer['experience'] ?? '0'} years",
              color: Colors.orange,
              scale: scale,
            ),
            SizedBox(height: 30 * scale),
            SizedBox(
              width: double.infinity,
              height: 50 * scale,
              child: ElevatedButton(
                onPressed: () {
                  final phone = trainer['phone'] ?? '';
                  if (phone.isEmpty) return;
                  _launchDialer(phone);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Contact Trainer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30 * scale),
          ],
        ),
      ),
    );
  }
}