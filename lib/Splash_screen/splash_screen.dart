import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
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

    connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) {
        showNetworkError();
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
    }
    if (kDebugMode) {
      print("Activity: $activity");
    }
    if (kDebugMode) {
      print("Sensors: $sensors");
    }
    if (kDebugMode) {
      print("BodySensors: $bodySensors");
    }
  }

  Future<void> requestBatteryOptimizationPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.health_and_safety, color: Color(0xFF4C3AFF)),
              SizedBox(width: 10),
              Text(
                "Permissions Required",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "FitTrack needs these permissions to track your steps accurately:",
                style: TextStyle(color: Colors.black87, fontSize: 15),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.directions_walk, color: Color(0xFF4C3AFF)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Activity Recognition\n(required for step counting)",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.sensors, color: Color(0xFF4C3AFF)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Motion Sensors\n(to detect steps even when screen is off)",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.battery_full, color: Color(0xFF4C3AFF)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Battery Optimization\n(prevents step tracking from stopping)",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await requestAllPermissions();
                navigateNext();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF4C3AFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
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

    Timer(Duration(seconds: 3), () {
      if (!mounted) return;
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomNav()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final textScale = width / 375;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4C3AFF), Color(0xFFA353FF),],
          ),
        ),

        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/logo.png", width: 180 * textScale),
              SizedBox(height: 24),
              Text(
                "FitTrack",
                style: TextStyle(
                  fontSize: 32 * textScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 6),
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
    );
  }

  void showNetworkError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text("Network Error", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'Please check your internet connection.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () => exit(0),
              child: Text("Exit", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }
}