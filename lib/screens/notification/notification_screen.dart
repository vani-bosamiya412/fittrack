import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool workoutReminders = true;
  bool weeklyReport = true;
  bool achievementAlerts = true;
  bool newWorkouts = false;
  bool musicUpdates = false;

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
          "Notification Settings",
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
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: Color(0xFFE9F1FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Stay Updated\nCustomize your notification preferences to stay on track with your fitness goals.",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14 * scale,
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(height: 24 * scale),

            _sectionTitle("General", scale),

            _settingsCard(
              children: [
                _toggleTile(
                  icon: Icons.notifications_none,
                  title: "Push Notifications",
                  subtitle: "Receive push notifications on your device",
                  scale: scale,
                  value: pushNotifications,
                  onChanged: (v) => setState(() => pushNotifications = v),
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.email_outlined,
                  title: "Email Notifications",
                  subtitle: "Receive updates via email",
                  scale: scale,
                  value: emailNotifications,
                  onChanged: (v) => setState(() => emailNotifications = v),
                ),
              ],
            ),

            SizedBox(height: 24 * scale),

            _sectionTitle("Workout & Progress", scale),

            _settingsCard(
              children: [
                _toggleTile(
                  icon: Icons.calendar_today_outlined,
                  title: "Workout Reminders",
                  subtitle: "Get reminded about your scheduled workouts",
                  scale: scale,
                  value: workoutReminders,
                  onChanged: (v) => setState(() => workoutReminders = v),
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.assessment_outlined,
                  title: "Weekly Progress Report",
                  subtitle: "Receive weekly summary of your progress",
                  scale: scale,
                  value: weeklyReport,
                  onChanged: (v) => setState(() => weeklyReport = v),
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.emoji_events_outlined,
                  title: "Achievement Alerts",
                  subtitle: "Get notified when you unlock achievements",
                  scale: scale,
                  value: achievementAlerts,
                  onChanged: (v) => setState(() => achievementAlerts = v),
                ),
              ],
            ),

            SizedBox(height: 24 * scale),

            _sectionTitle("Content Updates", scale),

            _settingsCard(
              children: [
                _toggleTile(
                  icon: Icons.fitness_center,
                  title: "New Workouts",
                  subtitle: "Notify about new workout programs",
                  scale: scale,
                  value: newWorkouts,
                  onChanged: (v) => setState(() => newWorkouts = v),
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.music_note,
                  title: "Music Updates",
                  subtitle: "Get notified about new workout playlists",
                  scale: scale,
                  value: musicUpdates,
                  onChanged: (v) => setState(() => musicUpdates = v),
                ),
              ],
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10 * scale),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required double scale,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              color: Color(0xFFE9F1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 22 * scale),
          ),

          SizedBox(width: 16 * scale),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    )),
                SizedBox(height: 4 * scale),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13 * scale,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.grey.shade300,
    );
  }
}