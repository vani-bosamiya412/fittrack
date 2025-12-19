import 'package:flutter/material.dart';
import '../auth/Login/login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "icon": Icons.fitness_center,
      "title": "Personalized Workouts",
      "desc":
          "Access hundreds of workouts tailored to your fitness level and goals. From beginners to advanced athletes.",
      "color1": Colors.blue,
      "color2": Colors.blueAccent,
    },
    {
      "icon": Icons.show_chart,
      "title": "Track Your Progress",
      "desc":
          "Monitor your daily activity, calories burned, and workout history with beautiful charts and insights.",
      "color1": Colors.purple,
      "color2": Colors.pinkAccent,
    },
    {
      "icon": Icons.apple,
      "title": "Nutrition Plans",
      "desc":
          "Get customized meal plans with detailed macros to support your fitness journey and achieve your goals.",
      "color1": Colors.green,
      "color2": Colors.greenAccent,
    },
    {
      "icon": Icons.music_note,
      "title": "Workout Music",
      "desc":
          "Stay motivated with curated workout playlists. Music that keeps you pumped throughout your training.",
      "color1": Colors.orange,
      "color2": Colors.deepOrangeAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final page = pages[index];

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.07),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: w * 0.04,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.2),

                      Container(
                        height: h * 0.22,
                        width: h * 0.22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [page["color1"], page["color2"]],
                          ),
                        ),
                        child: Icon(
                          page["icon"],
                          color: Colors.white,
                          size: h * 0.12,
                        ),
                      ),

                      SizedBox(height: h * 0.05),

                      Text(
                        page["title"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: w * 0.065,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: h * 0.015),

                      Text(
                        page["desc"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: w * 0.040,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),

                      Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: w * 0.012),
                            height: h * 0.01,
                            width: _currentIndex == index ? w * 0.06 : w * 0.02,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? Colors.blue
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.03),

                      SizedBox(
                        width: double.infinity,
                        height: h * 0.065,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentIndex < pages.length - 1) {
                              _controller.nextPage(
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            _currentIndex == pages.length - 1
                                ? "Get Started"
                                : "Next",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.02),

                      Text(
                        "${_currentIndex + 1} of ${pages.length}",
                        style: TextStyle(
                          fontSize: w * 0.036,
                          color: Colors.black45,
                        ),
                      ),

                      SizedBox(height: h * 0.02),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}