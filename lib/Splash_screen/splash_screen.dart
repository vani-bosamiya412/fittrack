import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Bottom_nav/bottom_nav.dart';
import '../Intro/intro.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool firstTime = await isFirstLaunch();

      if (firstTime) {
        showPermissionPopup();
      } else {
        navigateNext();
      }
    });
  }

  Future<void> requestActivityPermission() async {
    var activity = await Permission.activityRecognition.status;
    if (!activity.isGranted) {
      activity = await Permission.activityRecognition.request();
    }

    var sensors = await Permission.sensors.status;
    if (!sensors.isGranted) {
      sensors = await Permission.sensors.request();
    }

    var bodySensors = await Permission.sensors.status;
    if (!bodySensors.isGranted) {
      bodySensors = await Permission.sensors.request();
    }

    if (Platform.isAndroid) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    if (kDebugMode) {
      print("Permission status:");
      print("Activity: $activity");
      print("Sensors: $sensors");
      print("BodySensors: $bodySensors");
    }
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("permissions_granted") != true;
  }

  Future<void> setPermissionsGranted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("permissions_granted", true);
  }

  Future<void> requestAllPermissions() async {
    await Permission.activityRecognition.request();
    await Permission.sensors.request();

    if (Platform.isAndroid) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    await setPermissionsGranted();
  }

  void showPermissionPopup() {
    final media = MediaQuery.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final maxHeight = media.size.height * 0.6;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,

          title: Row(
            children: const [
              Icon(Icons.health_and_safety, color: Color(0xFF4C3AFF)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Permissions Required",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "FitTrack needs these permissions to track your steps accurately:",
                    style: TextStyle(color: Colors.black87, fontSize: 15),
                  ),
                  const SizedBox(height: 15),

                  _permissionRow(
                    Icons.directions_walk,
                    "Activity Recognition",
                    "Required for step counting",
                  ),
                  _permissionRow(
                    Icons.sensors,
                    "Motion Sensors",
                    "Detects steps even when screen is off",
                  ),
                  _permissionRow(
                    Icons.battery_full,
                    "Battery Optimization",
                    "Prevents step tracking from stopping",
                  ),
                ],
              ),
            ),
          ),

          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C3AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await requestAllPermissions();
                  navigateNext();
                },
                child: const Text(
                  "Allow Permissions",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void navigateNext() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isLoggedIn ? BottomNav() : OnboardingScreen(),
        ),
      );
    });
  }

  Widget _permissionRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4C3AFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final textScale = media.size.width / 375;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: media.size.width,
          height: media.size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4C3AFF), Color(0xFFA353FF)],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logo.png", width: 180 * textScale),
                const SizedBox(height: 24),
                Text(
                  "FitTrack",
                  style: TextStyle(
                    fontSize: 32 * textScale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Transform Your Body & Mind",
                  style: TextStyle(
                    fontSize: 16 * textScale,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}