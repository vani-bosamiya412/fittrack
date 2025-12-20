import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Music/music.dart';
import '../Nutrition/nutrition.dart';
import '../Progress/progress.dart';
import '../Workouts/workout.dart';
import '../Workouts/workout_detail_screen.dart';
import '../Trainer/trainer.dart';

class FitnessDashboard extends StatefulWidget {
  const FitnessDashboard({super.key});

  @override
  State<FitnessDashboard> createState() => _FitnessDashboardState();
}

class _FitnessDashboardState extends State<FitnessDashboard>
    with WidgetsBindingObserver {
  static const MethodChannel _platform = MethodChannel("fittrack/step_service");

  static const String _urlInsert =
      "https://prakrutitech.xyz/vani/insert_acivities.php";
  static const String _urlView =
      "https://prakrutitech.xyz/vani/view_activities.php";

  String userGender = "male";
  double userHeight = 170;
  double userWeight = 60;

  int totalWorkoutMinutes = 0;
  String? userName;
  Map<String, dynamic>? suggestedWorkout;
  bool isSuggestedLoading = true;

  final String fallbackImage =
      "/mnt/data/4562b084-9b4b-4473-8732-f3f29ae4eb09.png";

  int stepCount = 0;
  int baseSteps = 0;
  int activeMinutes = 0;
  double caloriesBurned = 0.0;
  double distanceKm = 0.0;

  Timer? _rawReaderTimer;
  Timer? _syncTimer;
  DateTime? _lastSynced;

  int _serverActivityIdForToday = 0;

  String _prefKey(String key, int userId) => "${key}_$userId";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _startStepServiceIfNeeded();
    _loadUserBodyInfo();
    _startRawReader();

    _loadWorkoutMinutes();
    _loadUserName();
    _loadSuggestedWorkout();

    _initTracking();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _startStepServiceIfNeeded();
      _fetchTodayActivityFromServerAndMerge();
    }
    if (state == AppLifecycleState.resumed) {
      final prefs = await SharedPreferences.getInstance();
      final today = _todayKey();
      final last = prefs.getString('last_step_date');

      if (last != today) {
        final raw = prefs.getInt('raw_steps') ?? 0;
        await prefs.setInt(
          _prefKey('steps_base', prefs.getInt('user_id')!),
          raw,
        );
        await prefs.setString('last_step_date', today);

        setState(() {
          baseSteps = raw;
          stepCount = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rawReaderTimer?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _startStepServiceIfNeeded() async {
    try {
      await _platform.invokeMethod("startStepService");
    } catch (e) {
      if (kDebugMode) print("startStepService error: $e");
    }
  }

  Future<void> _loadUserBodyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    userGender = prefs.getString("gender") ?? "male";
    userHeight = double.tryParse(prefs.getString("height") ?? "170") ?? 170;
    userWeight = double.tryParse(prefs.getString("weight") ?? "60") ?? 60;
  }

  Future<void> _loadWorkoutMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final email = prefs.getString('email') ?? 'guest';
      final key = 'totalWorkoutMinutes_$email';
      totalWorkoutMinutes = prefs.getInt(key) ?? 0;
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName =
          prefs.getString('name') ?? prefs.getString('username') ?? 'Guest';
    });
  }

  Future<void> _loadSuggestedWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('suggested_date');
    final savedData = prefs.getString('suggested_data');

    if (savedDate == today && savedData != null) {
      setState(() {
        suggestedWorkout = json.decode(savedData);
        isSuggestedLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://prakrutitech.xyz/vani/view_workout.php'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final randomWorkout = data[Random().nextInt(data.length)];
          setState(() {
            suggestedWorkout = randomWorkout;
            isSuggestedLoading = false;
          });
          prefs.setString('suggested_date', today);
          prefs.setString('suggested_data', json.encode(randomWorkout));
        }
      }
    } catch (e) {
      setState(() => isSuggestedLoading = false);
    }
  }

  void _startRawReader() {
    _rawReaderTimer?.cancel();

    const readInterval = Duration(seconds: 1);
    _rawReaderTimer = Timer.periodic(readInterval, (_) async {
      try {
        final dynamic result = await _platform.invokeMethod("getRawSteps");
        int raw = 0;
        if (result is int) {
          raw = result;
        } else if (result is String) {
          raw = int.tryParse(result) ?? 0;
        } else {
          raw = (result ?? 0) as int;
        }

        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('user_id') ?? -1;

        final todayKey = _todayKey();
        await _applyRawStepsSafely(
          raw,
          prefs,
          userId: userId,
          todayKey: todayKey,
        );
      } catch (e) {
        if (kDebugMode) print("getRawSteps error: $e");
        try {
          final prefs = await SharedPreferences.getInstance();
          final stored = prefs.getInt('raw_steps') ?? 0;
          final userId = prefs.getInt('user_id') ?? -1;
          await _applyRawStepsSafely(
            stored,
            prefs,
            userId: userId,
            todayKey: _todayKey(),
          );
        } catch (_) {}
      }
    });
  }

  double calculateDistance(int steps) {
    double heightM = userHeight / 100;
    double stepLength = (userGender.toLowerCase() == "female")
        ? (heightM * 0.413)
        : (heightM * 0.415);
    return (steps * stepLength) / 1000;
  }

  double calculateCalories(int steps, int activeMinutes) {
    double pace = activeMinutes > 0 ? (steps / activeMinutes) : 0;
    double calPerStep;
    if (pace < 80) {
      calPerStep = 0.035;
    } else if (pace < 120) {
      calPerStep = 0.055;
    } else {
      calPerStep = 0.09;
    }
    return steps * calPerStep;
  }

  int calculateMoveMinutes(int steps) {
    return (steps / 100).floor();
  }

  Future<void> _applyRawStepsSafely(
      int rawSteps,
      SharedPreferences prefs, {
        required int userId,
        required String todayKey,
      }) async {
    if (rawSteps > 0) {
      await prefs.setInt('raw_steps', rawSteps);
    } else {
      rawSteps = prefs.getInt('raw_steps') ?? 0;
    }

    final String lastSavedDate = prefs.getString('last_step_date') ?? todayKey;

    if (lastSavedDate != todayKey) {
      if (kDebugMode) print("DATE CHANGE DETECTED: $lastSavedDate -> $todayKey");

      await _finalizeYesterdayOnServer(userId, lastSavedDate);

      await prefs.setInt(_prefKey('steps_base', userId), rawSteps);
      await prefs.setString('last_step_date', todayKey);

      await prefs.setInt(_prefKey('steps_value', userId), 0);
      await prefs.setDouble(_prefKey('calories_value', userId), 0.0);
      await prefs.setInt(_prefKey('active_value', userId), 0);
      await prefs.remove(_prefKey('activity_id', userId));

      if (mounted) {
        setState(() {
          baseSteps = rawSteps;
          stepCount = 0;
          caloriesBurned = 0.0;
          activeMinutes = 0;
          distanceKm = 0.0;
        });
      }
      return;
    }

    int base = prefs.getInt(_prefKey('steps_base', userId)) ?? rawSteps;

    if (rawSteps < base) {
      base = rawSteps;
      await prefs.setInt(_prefKey('steps_base', userId), base);
    }

    int todaySteps = rawSteps - base;
    if (todaySteps < 0) todaySteps = 0;

    final int newActiveMinutes = calculateMoveMinutes(todaySteps);
    final double newCaloriesBurned = calculateCalories(todaySteps, newActiveMinutes);
    final double newDistanceKm = calculateDistance(todaySteps);

    if (todaySteps != stepCount) {
      if (mounted) {
        setState(() {
          stepCount = todaySteps;
          activeMinutes = newActiveMinutes;
          caloriesBurned = newCaloriesBurned;
          distanceKm = newDistanceKm;
        });
      }

      await prefs.setInt(_prefKey('steps_value', userId), todaySteps);
      await prefs.setDouble(_prefKey('calories_value', userId), newCaloriesBurned);
      await prefs.setInt(_prefKey('active_value', userId), newActiveMinutes);

      _scheduleSyncToServer(userId);
    }
  }

  Future<void> _finalizeYesterdayOnServer(
    int userId,
    String dateToFinalize,
  ) async {
    if (userId <= 0) return;

    final prefs = await SharedPreferences.getInstance();

    final int steps = prefs.getInt(_prefKey('steps_value', userId)) ?? 0;
    final double calories =
        prefs.getDouble(_prefKey('calories_value', userId)) ?? 0.0;
    final int active = prefs.getInt(_prefKey('active_value', userId)) ?? 0;
    final double distance = calculateDistance(steps);

    final int activityId = prefs.getInt(_prefKey('activity_id', userId)) ?? 0;

    try {
      if (activityId > 0) {
        await http.post(
          Uri.parse('https://prakrutitech.xyz/vani/update_activities.php'),
          body: {
            'id': activityId.toString(),
            'steps': steps.toString(),
            'distance': distance.toStringAsFixed(2),
            'duration': active.toString(),
            'calories': calories.toStringAsFixed(1),
            'activity_date': dateToFinalize,
          },
        );
      } else {
        await http.post(
          Uri.parse(_urlInsert),
          body: {
            'user_id': userId.toString(),
            'steps': steps.toString(),
            'distance': distance.toStringAsFixed(2),
            'duration': active.toString(),
            'calories': calories.toStringAsFixed(1),
            'activity_date': dateToFinalize,
          },
        );
      }

      if (kDebugMode) print("Finalized yesterday ($dateToFinalize) on server");
    } catch (e) {
      if (kDebugMode) print("Failed to finalize yesterday: $e");

      try {
        await http.post(
          Uri.parse(_urlInsert),
          body: {
            'user_id': userId.toString(),
            'steps': steps.toString(),
            'distance': distance.toStringAsFixed(2),
            'duration': active.toString(),
            'calories': calories.toStringAsFixed(1),
            'activity_date': dateToFinalize,
          },
        );
      } catch (e2) {
        if (kDebugMode) print("Fallback also failed: $e2");
      }
    }
  }

  void _scheduleSyncToServer(int userId) {
    if (userId <= 0) return;

    _syncTimer?.cancel();

    _syncTimer = Timer.periodic(Duration(seconds: 10), (_) async {
      await _syncNowToServer(userId);
    });

    _syncNowToServer(userId);
  }

  Future<void> _syncNowToServer(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String today = DateTime.now().toIso8601String().substring(0, 10);
      final String lastDate = prefs.getString('last_step_date') ?? today;

      if (lastDate != today) {
        return;
      }

      final int localSteps = stepCount;
      final double localCalories = caloriesBurned;
      final int localActive = activeMinutes;
      final double distance = calculateDistance(localSteps);

      final response = await http
          .post(
            Uri.parse(_urlInsert),
            body: {
              'user_id': userId.toString(),
              'steps': localSteps.toString(),
              'distance': distance.toStringAsFixed(2),
              'duration': localActive.toString(),
              'calories': localCalories.toStringAsFixed(1),
              'activity_date': today,
            },
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        _lastSynced = DateTime.now();

        try {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['id'] != null) {
            final int sid = int.tryParse(data['id'].toString()) ?? 0;
            if (sid > 0) {
              await prefs.setInt(_prefKey('activity_id', userId), sid);
              _serverActivityIdForToday = sid;
            }
          }
        } catch (e) {
          // Ignore parse errors
        }
      }
    } catch (e) {
      // Silent fail - will retry on next sync
    }
  }

  Future<Map?> _fetchActivityForUserDate(int userId, String date) async {
    try {
      final uri = Uri.parse("$_urlView?user_id=$userId");
      final resp = await http.get(uri).timeout(Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);

        if (data is List) {
          for (final e in data) {
            if (e is Map &&
                (e['activity_date'] ?? '').toString().startsWith(date)) {
              return Map<String, dynamic>.from(e);
            }
          }
        } else if (data is Map) {
          final adate = (data['activity_date'] ?? '').toString();
          if (adate.startsWith(date)) return Map<String, dynamic>.from(data);
        } else {
          if (resp.body.trim().startsWith("[")) {
            final parsed = json.decode(resp.body);
            if (parsed is List) {
              for (final e in parsed) {
                if (e is Map &&
                    (e['activity_date'] ?? '').toString().startsWith(date)) {
                  return Map<String, dynamic>.from(e);
                }
              }
            }
          }
        }
      } else {
        // if (kDebugMode) print("fetchActivity HTTP ${resp.statusCode}");
      }
    } catch (e) {
      // if (kDebugMode) print("fetchActivity error: $e");
    }
    return null;
  }

  Future<void> _fetchTodayActivityFromServerAndMerge() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? -1;
    if (userId <= 0) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final serverActivity = await _fetchActivityForUserDate(userId, today);

    final localSteps =
        prefs.getInt(_prefKey('steps_value', userId)) ?? stepCount;

    if (serverActivity != null) {
      final serverSteps = int.tryParse(serverActivity['steps'].toString()) ?? 0;
      final serverCalories =
          double.tryParse(serverActivity['calories'].toString()) ?? 0.0;
      final serverActive =
          int.tryParse(serverActivity['duration'].toString()) ?? 0;
      final serverId = int.tryParse(serverActivity['id'].toString()) ?? 0;

      if (serverId > 0) {
        prefs.setInt(_prefKey('activity_id', userId), serverId);
        _serverActivityIdForToday = serverId;
      }

      final lastDate = prefs.getString('last_step_date');
      if (lastDate != today) {
        return;
      }

      if (serverSteps > localSteps) {
        prefs.setInt(_prefKey('steps_value', userId), serverSteps);
        prefs.setDouble(_prefKey('calories_value', userId), serverCalories);
        prefs.setInt(_prefKey('active_value', userId), serverActive);
        setState(() {
          stepCount = serverSteps;
          caloriesBurned = serverCalories;
          activeMinutes = serverActive;
        });
      } else {
        if (kDebugMode) {
          // print(
          //   "Local steps ($localSteps) >= server steps ($serverSteps): keeping local",
          // );
        }
      }
    } else {
      if (kDebugMode) {
        print("No server activity for today; will insert on sync");
      }
    }

    _scheduleSyncToServer(userId);
  }

  Future<void> _initTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? -1;
    final String todayStr = DateTime.now().toIso8601String().substring(0, 10);

    final String savedDate = prefs.getString('last_step_date') ?? todayStr;

    if (savedDate != todayStr) {
      final int raw = prefs.getInt('raw_steps') ?? 0;
      await prefs.setInt(_prefKey('steps_base', userId), raw);
      await prefs.setString('last_step_date', todayStr);
      await prefs.setInt(_prefKey('steps_value', userId), 0);
      await prefs.setDouble(_prefKey('calories_value', userId), 0.0);
      await prefs.setInt(_prefKey('active_value', userId), 0);
      await prefs.remove(_prefKey('activity_id', userId));

      if (userId > 0) {
        await http.post(
          Uri.parse(_urlInsert),
          body: {
            'user_id': userId.toString(),
            'steps': '0',
            'distance': '0',
            'duration': '0',
            'calories': '0',
            'activity_date': todayStr,
          },
        );
      }
    }

    final savedSteps = prefs.getInt(_prefKey('steps_value', userId)) ?? 0;
    final savedBase = prefs.getInt(_prefKey('steps_base', userId)) ?? 0;
    final savedCalories =
        prefs.getDouble(_prefKey('calories_value', userId)) ?? 0.0;
    final savedActive = prefs.getInt(_prefKey('active_value', userId)) ?? 0;

    if (mounted) {
      setState(() {
        stepCount = savedSteps;
        baseSteps = savedBase;
        caloriesBurned = savedCalories;
        activeMinutes = savedActive;
        distanceKm = calculateDistance(savedSteps);
      });
    }

    if (userId > 0) {
      await _fetchTodayActivityFromServerAndMerge();
    }
  }

  String _todayKey() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    const stepsColor = Color(0xFF3B82F6);
    const caloriesColor = Color(0xFFF97316);
    const activeTimeColor = Color(0xFF10B981);
    const workoutsColor = Color(0xFFA78BFA);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        title: Text(
          "Dashboard",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _initTracking();
          await _loadWorkoutMinutes();
          await _loadUserName();
        },
        color: Color(0xFFA353FF),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: width * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.045),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF5B21B6),
                      Color(0xFF8B5CF6),
                      Color(0xFFB07BFF),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Hello, ${userName ?? 'Guest'}!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text("👋", style: TextStyle(fontSize: 24)),
                      ],
                    ),
                    SizedBox(height: width * 0.02),
                    Text(
                      "Ready to crush your fitness goals today?",
                      style: TextStyle(
                        color: Colors.white.withAlpha(230),
                        fontSize: width * 0.037,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: width * 0.05),
              Text(
                "Today's Activity",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: width * 0.035),

              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _smallActivityCard(
                          title: "Steps",
                          value: "$stepCount",
                          icon: Icons.directions_walk,
                          iconBg: stepsColor.withAlpha(30),
                          iconColor: stepsColor,
                          width: width,
                        ),
                      ),
                      SizedBox(width: width * 0.04),
                      Expanded(
                        child: _smallActivityCard(
                          title: "Calories",
                          value: "${caloriesBurned.toStringAsFixed(1)} kcal",
                          icon: Icons.local_fire_department,
                          iconBg: caloriesColor.withAlpha(30),
                          iconColor: caloriesColor,
                          width: width,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.035),
                  Row(
                    children: [
                      Expanded(
                        child: _smallActivityCard(
                          title: "Active Time",
                          value: "$activeMinutes min",
                          icon: Icons.watch_later_outlined,
                          iconBg: activeTimeColor.withAlpha(30),
                          iconColor: activeTimeColor,
                          width: width,
                        ),
                      ),
                      SizedBox(width: width * 0.04),
                      Expanded(
                        child: _smallActivityCard(
                          title: "Workouts",
                          value: "$totalWorkoutMinutes min",
                          icon: Icons.fitness_center,
                          iconBg: workoutsColor.withAlpha(30),
                          iconColor: workoutsColor,
                          width: width,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: width * 0.05),
              Text(
                "Find Trainers",
                style: TextStyle(
                  fontSize: width * 0.047,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: width * 0.03),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TrainerScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(width * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: width * 0.15,
                        width: width * 0.15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Color(0xFF4C3AFF), Color(0xFFA353FF)],
                          ),
                        ),
                        child: Icon(
                          Icons.person_search,
                          color: Colors.white,
                          size: width * 0.085,
                        ),
                      ),
                      SizedBox(width: width * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Find Trainers",
                              style: TextStyle(
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Explore certified trainers",
                              style: TextStyle(
                                fontSize: width * 0.036,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.black26,
                        size: width * 0.07,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: width * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Suggested for You",
                    style: TextStyle(
                      fontSize: width * 0.047,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WorkoutScreen()),
                    ),
                    child: Text(
                      "View All",
                      style: TextStyle(
                        fontSize: width * 0.038,
                        color: Color(0xFF6D28D9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: width * 0.03),
              isSuggestedLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.purple),
                    )
                  : suggestedWorkout == null
                  ? Text("No suggestions available.")
                  : GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(
                            workoutId: int.parse(
                              suggestedWorkout!['id'].toString(),
                            ),
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: width * 0.44,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                                child: buildWorkoutThumbnail(
                                  suggestedWorkout!['video_url'] ?? "",
                                  width * 0.44,
                                  18,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestedWorkout!['title'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    suggestedWorkout!['description'] ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.timer_outlined, size: 18),
                                      SizedBox(width: 5),
                                      Text(
                                        "${suggestedWorkout!['duration']} min",
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _difficultyColor(
                                        suggestedWorkout!['difficulty'],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      suggestedWorkout!['difficulty'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

              SizedBox(height: width * 0.03),
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: width * 0.047,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: width * 0.03),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: width * 0.04,
                mainAxisSpacing: width * 0.04,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 1.7,
                children: [
                  _actionCard(
                    title: "Browse Workouts",
                    icon: Icons.fitness_center,
                    iconBg: Color(0xFFEFF6FF),
                    iconColor: Color(0xFF3B82F6),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WorkoutScreen()),
                    ),
                  ),
                  _actionCard(
                    title: "Nutrition Plans",
                    icon: Icons.restaurant,
                    iconBg: Color(0xFFF0FDF4),
                    iconColor: Color(0xFF10B981),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NutritionManagementScreen(),
                      ),
                    ),
                  ),
                  _actionCard(
                    title: "Track Progress",
                    icon: Icons.bar_chart,
                    iconBg: Color(0xFFFFF7ED),
                    iconColor: Color(0xFFF97316),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgressScreen(
                          steps: stepCount,
                          calories: caloriesBurned,
                          activeMinutes: activeMinutes,
                          workouts: totalWorkoutMinutes,
                        ),
                      ),
                    ),
                  ),
                  _actionCard(
                    title: "Workout Music",
                    icon: Icons.music_note,
                    iconBg: Color(0xFFF5F3FF),
                    iconColor: Color(0xFFA78BFA),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MusicScreen()),
                    ),
                  ),
                ],
              ),

              SizedBox(height: width * 0.12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallActivityCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required double width,
  }) {
    return Container(
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.03),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: width * 0.07, color: iconColor),
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: width * 0.045,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: width * 0.035,
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

  Widget _actionCard({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final double iconSize = 28;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: iconSize, color: iconColor),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget fallbackGradient(double height, double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6DD3FF), Color(0xFFB27CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  bool isYouTube(String url) =>
      url.contains("youtube.com") || url.contains("youtu.be");

  String youtubeThumbnail(String url) {
    try {
      final id = Uri.tryParse(url)?.queryParameters['v'];
      if (id != null) return "https://img.youtube.com/vi/$id/hqdefault.jpg";
      final uri = Uri.tryParse(url);
      if (uri != null && uri.host.contains("youtu.be")) {
        return "https://img.youtube.com/vi/${uri.pathSegments[0]}/hqdefault.jpg";
      }
      final match = RegExp(r"([0-9A-Za-z_-]{11})").firstMatch(url);
      if (match != null) {
        return "https://img.youtube.com/vi/${match.group(1)}/hqdefault.jpg";
      }
    } catch (_) {}
    return fallbackImage;
  }

  bool isImage(String url) =>
      url.endsWith(".jpg") ||
      url.endsWith(".jpeg") ||
      url.endsWith(".png") ||
      url.endsWith(".gif");

  bool isVideo(String url) =>
      url.endsWith(".mp4") || url.endsWith(".mov") || url.endsWith(".avi");

  Widget buildWorkoutThumbnail(String url, double height, double radius) {
    url = url.trim();
    if (url.isEmpty) {
      final file = File(fallbackImage);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            height: height,
            width: double.infinity,
          ),
        );
      }
      return fallbackGradient(height, radius);
    }
    if (isYouTube(url)) {
      final thumb = youtubeThumbnail(url);
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          thumb,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallbackGradient(height, radius),
        ),
      );
    }
    if (isImage(url)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          url,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallbackGradient(height, radius),
        ),
      );
    }
    if (isVideo(url)) return fallbackGradient(height, radius);
    return fallbackGradient(height, radius);
  }

  static Color _difficultyColor(String level) {
    switch (level) {
      case "Beginner":
        return Colors.green;
      case "Intermediate":
        return Colors.orange;
      case "Advanced":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}