import 'package:flutter/material.dart';

class MyAchievementsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> earned = [
    {
      "icon": Icons.bolt,
      "title": "First Workout",
      "subtitle": "Complete your first workout session",
      "date": "Nov 15, 2024",
      "color": Colors.amber,
    },
    {
      "icon": Icons.calendar_month,
      "title": "7 Day Streak",
      "subtitle": "Work out for 7 consecutive days",
      "date": "Nov 20, 2024",
      "color": Colors.blue,
    },
    {
      "icon": Icons.local_fire_department,
      "title": "Calorie Burner",
      "subtitle": "Burn 1000 calories in a single workout",
      "date": "Nov 22, 2024",
      "color": Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> locked = [
    {
      "icon": Icons.lock_clock,
      "title": "30 Day Warrior",
      "subtitle": "Work out for 30 consecutive days",
    },
    {
      "icon": Icons.track_changes,
      "title": "Goal Achiever",
      "subtitle": "Reach your fitness goal",
    },
    {
      "icon": Icons.star,
      "title": "Perfect Month",
      "subtitle": "Complete all planned workouts in a month",
    },
  ];

  MyAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "My Achievements",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Color(0xFF7F7BFF), Color(0xFF4A3AFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.emoji_events, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    "3 / 6",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Achievements Unlocked",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
            Text(
              "Earned",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),

            ...earned.map(
              (item) => achievementTile(
                icon: item["icon"],
                color: item["color"],
                title: item["title"],
                subtitle: item["subtitle"],
                date: item["date"],
                locked: false,
              ),
            ),

            SizedBox(height: 12),
            Text(
              "Locked",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),

            ...locked.map(
              (item) => achievementTile(
                icon: item["icon"],
                color: Colors.grey,
                title: item["title"],
                subtitle: item["subtitle"],
                locked: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget achievementTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    String? date,
    bool locked = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: locked ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: locked ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
        boxShadow: locked
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: locked ? Colors.grey.shade300 : color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: locked ? Colors.grey : color, size: 24),
          ),
          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: locked ? Colors.grey : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                if (!locked && date != null) ...[
                  SizedBox(height: 6),
                  Text(
                    "Earned on $date",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}