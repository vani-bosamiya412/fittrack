import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'workout_detail_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<dynamic> workouts = [];
  bool isLoading = true;

  String selectedCategory = "All";
  bool showFilters = false;
  String filterDifficulty = "All";
  String searchQuery = "";

  final List<String> categories = [
    "All",
    "Cardio",
    "Strength",
    "Yoga",
    "Pilates",
    "HIIT",
    "Other",
  ];

  final String fallbackImage =
      "/mnt/data/4562b084-9b4b-4473-8732-f3f29ae4eb09.png";

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    try {
      final response = await http.get(
        Uri.parse('https://prakrutitech.xyz/vani/view_workout.php'),
      );

      if (response.statusCode == 200) {
        workouts = json.decode(response.body);
        isLoading = false;
        setState(() {});
      } else {
        throw Exception("Failed to load workouts");
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading workouts")));
    }
  }

  List<dynamic> _filteredWorkouts() {
    List<dynamic> list = workouts;

    if (selectedCategory != "All") {
      list = list.where((w) => w['category'] == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      list = list.where((w) {
        final q = searchQuery.toLowerCase();
        return w['title'].toString().toLowerCase().contains(q) ||
            w['description'].toString().toLowerCase().contains(q);
      }).toList();
    }

    if (filterDifficulty != "All") {
      list = list.where((w) => w['difficulty'] == filterDifficulty).toList();
    }

    return list;
  }

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

    if (isVideo(url)) {
      return fallbackGradient(height, radius);
    }

    return fallbackGradient(height, radius);
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

  Color getDifficultyColor(String level) {
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredWorkouts();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final sw = width / 375;
    final sh = height / 812;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          "Workouts",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchWorkouts();
        },
        color: Color(0xFFA353FF),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              )
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * sw,
                      vertical: 10 * sh,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12 * sw,
                              vertical: 3 * sh,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12 * sw),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 20 * sw,
                                  color: Colors.grey.shade700,
                                ),
                                SizedBox(width: 8 * sw),
                                Expanded(
                                  child: TextField(
                                    onChanged: (v) => setState(
                                      () => searchQuery = v.toLowerCase().trim(),
                                      ),
                                    style: TextStyle(
                                      fontSize: 16 * sw,
                                      color: Colors.black
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Search workouts...",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10 * sw),
                        GestureDetector(
                          onTap: () => setState(() => showFilters = !showFilters),
                          child: Container(
                            padding: EdgeInsets.all(10 * sw),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12 * sw),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(
                              Icons.tune,
                              size: 22 * sw,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedCrossFade(
                    firstChild: SizedBox.shrink(),
                    secondChild: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * sw,
                        vertical: 8 * sh,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12 * sw),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12 * sw),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedCategory,
                                    items: categories
                                        .map(
                                          (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: TextStyle(fontSize: 15 * sw),
                                        ),
                                      ),
                                    )
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => selectedCategory = val!),
                                    decoration: inputDecoration(sw),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                SizedBox(width: 12 * sw),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: filterDifficulty,
                                    items: [
                                      DropdownMenuItem(
                                        value: "All",
                                        child: Text("All"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Beginner",
                                        child: Text("Beginner"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Intermediate",
                                        child: Text("Intermediate"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Advanced",
                                        child: Text("Advanced"),
                                      ),
                                    ],
                                    onChanged: (val) =>
                                        setState(() => filterDifficulty = val!),
                                    decoration: inputDecoration(sw),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15 * sw,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12 * sh),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.shade200,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12 * sh,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8 * sw),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedCategory = "All";
                                    filterDifficulty = "All";
                                    searchQuery = "";
                                  });
                                },
                                child: Text(
                                  "Clear Filters",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15 * sw,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    crossFadeState: showFilters
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: Duration(milliseconds: 200),
                  ),
                  SizedBox(
                    height: 45 * sh,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 12 * sw),
                      children: categories.map((cat) {
                        final selected = selectedCategory == cat;
                        return Padding(
                          padding: EdgeInsets.only(right: 10 * sw),
                          child: ChoiceChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black,
                                fontSize: 14 * sw,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => selectedCategory = cat),
                            selectedColor: Colors.blueAccent,
                            backgroundColor: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 10 * sh),

                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16 * sw),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final w = filtered[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkoutDetailScreen(
                                  workoutId: int.parse(w['id']),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20 * sh),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18 * sw),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6 * sw,
                                  spreadRadius: 1 * sw,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 150 * sh,
                                  width: double.infinity,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(18 * sw),
                                        ),
                                        child: buildWorkoutThumbnail(
                                          w['video_url'] ?? "",
                                          150 * sh,
                                          18 * sw,
                                        ),
                                      ),

                                      Positioned(
                                        left: 10,
                                        bottom: 10,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.7),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            w['category'] ?? "Other",
                                            style: TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: getDifficultyColor(w['difficulty']),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            w['difficulty'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(12 * sw),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        w['title'],
                                        style: TextStyle(
                                          fontSize: 18 * sw,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
                                        ),
                                      ),
                                      SizedBox(height: 4 * sh),
                                      Text(
                                        w['description'] ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14 * sw,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 10 * sh),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 18 * sw,
                                            color: Colors.black,
                                          ),
                                          SizedBox(width: 5 * sw),
                                          Text(
                                            "${w['duration']} min",
                                            style: TextStyle(
                                              fontSize: 14 * sw,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8 * sh),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  InputDecoration inputDecoration(double sw) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12 * sw,
        vertical: 10 * sw,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8 * sw),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}