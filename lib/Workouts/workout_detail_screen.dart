import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final int workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  Map<String, dynamic>? workout;
  bool isLoading = true;
  VideoPlayerController? _videoController;
  final String detailApiUrl = "https://prakrutitech.xyz/vani/view_workout.php";

  Timer? timer;
  int secondsLeft = 0;
  bool isRunning = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    fetchWorkoutDetail();
  }

  @override
  void dispose() {
    timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> fetchWorkoutDetail() async {
    try {
      final response = await http.get(
        Uri.parse("$detailApiUrl?id=${widget.workoutId}"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          workout = data;
          isLoading = false;
          secondsLeft =
              int.tryParse(workout?['duration'].toString() ?? '0')! * 60;
        });

        final url = data['video_url'] ?? '';
        if (_isDirectVideo(url)) {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
            ..initialize().then((_) {
              setState(() {});
            });
        }
      } else {
        _showError("Failed to load workout details");
      }
    } catch (_) {
      _showError("Error fetching workout details");
    }
  }

  void _showError(String message) {
    setState(() => isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void startWorkout() {
    if (isRunning) return;
    setState(() {
      isRunning = true;
      isPaused = false;
    });
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (secondsLeft > 0 && !isPaused) {
        setState(() => secondsLeft--);
      } else if (secondsLeft <= 0) {
        t.cancel();
        completeWorkout();
      }
    });
  }

  void pauseWorkout() => setState(() => isPaused = true);

  void resumeWorkout() => setState(() => isPaused = false);

  Future<void> completeWorkout() async {
    timer?.cancel();
    setState(() {
      isRunning = false;
      isPaused = false;
    });

    final totalSeconds =
        (int.tryParse(workout?['duration'].toString() ?? '0') ?? 0) * 60;
    final secondsCompleted = totalSeconds - secondsLeft;
    final minutesCompleted = (secondsCompleted / 60).round();

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? 'guest';
    final key = 'totalWorkoutMinutes_$email';
    int totalMinutes = prefs.getInt(key) ?? 0;
    totalMinutes += minutesCompleted;
    await prefs.setInt(key, totalMinutes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout saved: $minutesCompleted min completed!'),
        ),
      );
      Navigator.pop(context);
    }
  }

  bool _isImage(String url) =>
      url.endsWith(".jpg") ||
          url.endsWith(".jpeg") ||
          url.endsWith(".png") ||
          url.endsWith(".gif") ||
          url.contains("image");

  bool _isDirectVideo(String url) =>
      url.endsWith(".mp4") ||
          url.endsWith(".mov") ||
          url.endsWith(".avi") ||
          url.contains("video");

  bool _isYouTubeLink(String url) =>
      url.contains("youtube.com") || url.contains("youtu.be");

  String formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  final String fallbackLocalImage = '/mnt/data/4562b084-9b4b-4473-8732-f3f29ae4eb09.png';

  String? _youtubeThumbnail(String url) {
    try {
      final id = Uri.tryParse(url)?.queryParameters['v'];
      if (id != null && id.isNotEmpty) return "https://img.youtube.com/vi/$id/hqdefault.jpg";
      final uri = Uri.tryParse(url);
      if (uri != null && uri.host.contains('youtu.be')) {
        final seg = uri.pathSegments;
        if (seg.isNotEmpty) return "https://img.youtube.com/vi/${seg[0]}/hqdefault.jpg";
      }
      final match = RegExp(r'(?:v=|/)([0-9A-Za-z_-]{11}).*').firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return "https://img.youtube.com/vi/${match.group(1)}/hqdefault.jpg";
      }
    } catch (_) {}
    return null;
  }

  Widget _buildThumbnail(String url, double scale) {
    if (url.trim().isEmpty) {
      final file = File(fallbackLocalImage);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12 * scale),
          child: Image.file(
            file,
            height: 220 * scale,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }
      return Container(
        height: 220 * scale,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6DD3FF), Color(0xFFB27CFF)],
          ),
          borderRadius: BorderRadius.circular(12 * scale),
        ),
      );
    }

    if (_isYouTubeLink(url)) {
      final thumb = _youtubeThumbnail(url);
      if (thumb != null) {
        return GestureDetector(
          onTap: () async {
            final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12 * scale),
            child: Stack(
              children: [
                Image.network(
                  thumb,
                  height: 220 * scale,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 220 * scale,
                      color: Colors.grey.shade200,
                    );
                  },
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      padding: EdgeInsets.all(10 * scale),
                      child: Icon(Icons.play_arrow, size: 56 * scale, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (_isDirectVideo(url)) {
      return GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12 * scale),
          child: Container(
            height: 220 * scale,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6DD3FF), Color(0xFFB27CFF)],
              ),
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                padding: EdgeInsets.all(10 * scale),
                child: Icon(Icons.play_arrow, size: 56 * scale, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }

    if (_isImage(url)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12 * scale),
        child: Image.network(
          url,
          height: 220 * scale,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              height: 220 * scale,
              color: Colors.grey.shade200,
            );
          },
        ),
      );
    }

    return Container(
      height: 220 * scale,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6DD3FF), Color(0xFFB27CFF)],
        ),
        borderRadius: BorderRadius.circular(12 * scale),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      backgroundColor: Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Text(
          workout?['title'] ?? 'Workout Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : workout == null
          ? Center(child: Text("Workout not found"))
          : Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 140 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14 * scale),
                    child: Stack(
                      children: [
                        _buildThumbnail(workout!['video_url'] ?? '', scale),
                        Positioned(
                          top: 12 * scale,
                          right: 12 * scale,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20 * scale),
                            ),
                            child: Text(
                              workout!['difficulty'],
                              style: TextStyle(
                                fontSize: 12 * scale,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Row(
                    children: [
                      _infoCard(
                        icon: Icons.timer_outlined,
                        iconColor: Color(0xFF2979FF),
                        title: '${workout!['duration'] ?? 0} min',
                        subtitle: "Duration",
                        scale: scale,
                      ),
                      SizedBox(width: 12 * scale),
                      _infoCard(
                        icon: Icons.fitness_center_outlined,
                        iconColor: Color(0xFFFFB300),
                        title: workout!['category'] ?? 'Other',
                        subtitle: "Type",
                        scale: scale,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18 * scale),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About This Workout",
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          workout!['description'] ??
                              'High-intensity interval training to burn calories and build strength',
                          style: TextStyle(fontSize: 14 * scale, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 24 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: Offset(0, -6),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10 * scale, horizontal: 14 * scale),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isRunning ? "Time left: " : "Timer: ",
                      style: TextStyle(fontSize: 12 * scale, color: Colors.black54),
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      formatTime(secondsLeft),
                      style: TextStyle(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12 * scale),
              SizedBox(
                width: double.infinity,
                height: 52 * scale,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (!isRunning) {
                      startWorkout();
                    } else if (isPaused) {
                      resumeWorkout();
                    } else {
                      pauseWorkout();
                    }
                  },
                  icon: Icon(Icons.play_arrow, color: Colors.white),
                  label: Text(
                    !isRunning ? "Start Workout" : (isPaused ? "Resume" : "Pause"),
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                  ),
                ),
              ),
              if (isRunning) ...[
                SizedBox(height: 8 * scale),
                TextButton.icon(
                  onPressed: completeWorkout,
                  icon: Icon(Icons.stop, color: Colors.redAccent),
                  label: Text(
                    "End Workout Early",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14 * scale,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double scale,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8 * scale),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Icon(icon, size: 22 * scale, color: iconColor),
            ),
            SizedBox(height: 8 * scale),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * scale, color: Colors.black),
            ),
            SizedBox(height: 4 * scale),
            Text(subtitle, style: TextStyle(fontSize: 12 * scale, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}