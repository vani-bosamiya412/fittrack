import 'package:flutter/material.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

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
          "Help & Support",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12 * scale),

            Row(
              children: [
                Expanded(
                  child: _quickAction(
                    icon: Icons.email_outlined,
                    label: "Email Support",
                    color: Colors.blue,
                    scale: scale,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _quickAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: "Live Chat",
                    color: Colors.green,
                    scale: scale,
                  ),
                ),
              ],
            ),

            SizedBox(height: 28 * scale),

            Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12 * scale),

            _faqCard(
              scale: scale,
              question: "How do I track my workouts?",
              answer:
                  "Navigate to the Workouts tab and select any workout. Your progress will be automatically tracked.",
            ),
            _faqCard(
              scale: scale,
              question: "Can I customize my nutrition plan?",
              answer:
                  "Yes! Go to the Nutrition tab and tap on any plan to view details and customize it to your needs.",
            ),
            _faqCard(
              scale: scale,
              question: "How do I contact a trainer?",
              answer:
                  "Visit the Trainers section, select a trainer, and tap the Contact button to reach out via phone.",
            ),
            _faqCard(
              scale: scale,
              question: "Where can I see my achievements?",
              answer:
                  "Go to Profile > My Achievements to view all your earned and locked achievements.",
            ),

            SizedBox(height: 28 * scale),

            Text(
              "Send Us a Message",
              style: TextStyle(
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12 * scale),

            _formCard(scale),

            SizedBox(height: 28 * scale),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: Color(0xFFE9F1FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Email: support@fitlife.com\n"
                "Hours: Mon–Fri, 9AM–6PM EST\n"
                "Response time: Within 24 hours",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13 * scale,
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22 * scale, color: color),
          ),
          SizedBox(height: 8 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqCard({
    required double scale,
    required String question,
    required String answer,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14 * scale),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.help_outline,
              size: 22 * scale,
              color: Colors.purpleAccent,
            ),
          ),
          SizedBox(width: 14 * scale),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  answer,
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

  Widget _formCard(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputLabel("Subject", scale),
          _inputField(
            subjectController,
            scale,
            hint: "What do you need help with?",
          ),

          SizedBox(height: 14 * scale),

          _inputLabel("Message", scale),
          _inputField(
            messageController,
            scale,
            hint: "Describe your issue or question...",
            maxLines: 4,
          ),

          SizedBox(height: 16 * scale),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 14 * scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.send, color: Colors.white),
              label: Text(
                "Send Message",
                style: TextStyle(color: Colors.white, fontSize: 15 * scale),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputLabel(String text, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * scale),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14 * scale,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    double scale, {
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
      decoration: BoxDecoration(
        color: Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}