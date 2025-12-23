import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool darkMode = false;
  String language = "English";
  String measurementSystem = "Metric (kg, cm, km)";
  bool autoPlayVideos = true;

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
          "App Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Display", scale),

            _settingsCard(
              child: Column(
                children: [
                  _switchTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: Colors.purpleAccent,
                    title: "Dark Mode",
                    subtitle: "Use dark theme across the app",
                    value: darkMode,
                    scale: scale,
                    onChanged: (v) => setState(() => darkMode = v),
                  ),

                  _divider(),

                  _dropdownTile(
                    icon: Icons.language,
                    iconColor: Colors.blueAccent,
                    title: "Language",
                    value: language,
                    options: ["English", "Hindi", "Spanish"],
                    scale: scale,
                    onChanged: (v) => setState(() => language = v),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24 * scale),

            _sectionTitle("Units & Measurements", scale),

            _settingsCard(
              child: _dropdownTile(
                icon: Icons.straighten,
                iconColor: Colors.green,
                title: "Measurement System",
                value: measurementSystem,
                options: ["Metric (kg, cm, km)", "Imperial (lbs, ft, miles)"],
                scale: scale,
                onChanged: (v) => setState(() => measurementSystem = v),
              ),
            ),

            SizedBox(height: 24 * scale),

            _sectionTitle("Media", scale),

            _settingsCard(
              child: _switchTile(
                icon: Icons.volume_up_outlined,
                iconColor: Colors.orangeAccent,
                title: "Auto-play Videos",
                subtitle: "Automatically play workout videos",
                value: autoPlayVideos,
                scale: scale,
                onChanged: (v) => setState(() => autoPlayVideos = v),
              ),
            ),

            SizedBox(height: 24 * scale),

            _sectionTitle("App Information", scale),

            _settingsCard(
              child: Column(
                children: [
                  _infoTile(
                    icon: Icons.mobile_friendly,
                    title: "App Version",
                    value: "1.0.0",
                    scale: scale,
                  ),
                  _divider(),
                  _infoTile(
                    icon: Icons.build_outlined,
                    title: "Build Number",
                    value: "2025.11.24",
                    scale: scale,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24 * scale),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: Color(0xFFE9F1FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Changes to language and unit settings will take effect after restarting the app.",
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

  Widget _settingsCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required double scale,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 14 * scale,
      ),
      child: Row(
        children: [
          _iconBox(icon, iconColor, scale),

          SizedBox(width: 16 * scale),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13 * scale, color: Colors.black54),
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

  Widget _dropdownTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> options,
    required double scale,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 14 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(icon, iconColor, scale),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10 * scale),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            decoration: BoxDecoration(
              color: Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                items: options
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => onChanged(v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    required double scale,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 14 * scale,
      ),
      child: Row(
        children: [
          _iconBox(icon, Colors.grey, scale),
          SizedBox(width: 16 * scale),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(fontSize: 14 * scale, color: Colors.black54),
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

  Widget _iconBox(IconData icon, Color color, double scale) {
    return Container(
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22 * scale),
    );
  }
}