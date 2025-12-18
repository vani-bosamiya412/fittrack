import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'trainer_detail_screen.dart';
import 'Become_trainer/become_trainer.dart';

class TrainerScreen extends StatefulWidget {
  const TrainerScreen({super.key});

  @override
  State<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends State<TrainerScreen> {
  List<dynamic> trainers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrainers();
  }

  Future<void> fetchTrainers() async {
    const url = 'https://prakrutitech.xyz/vani/get_trainers.php';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final filtered = data.where((t) {
          final status = (t['status'] ?? '').toString().toLowerCase();
          return status == 'approved';
        }).toList();

        setState(() {
          trainers = filtered;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load trainers');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching trainers: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      backgroundColor: Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Trainers",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : trainers.isEmpty
          ? Center(
              child: Text(
                'No approved trainers available yet!',
                style: TextStyle(fontSize: 16 * scale),
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchTrainers,
              child: ListView.builder(
                padding: EdgeInsets.all(16 * scale),
                itemCount: trainers.length,
                itemBuilder: (context, index) {
                  final t = trainers[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrainerDetailScreen(trainer: t),
                        ),
                      );
                    },

                    child: Container(
                      margin: EdgeInsets.only(bottom: 16 * scale),
                      padding: EdgeInsets.all(14 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 55 * scale,
                            height: 55 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF4C3AFF), Color(0xFFA353FF)],
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),

                          SizedBox(width: 14 * scale),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t["name"] ?? "Unknown",
                                  style: TextStyle(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: 5 * scale),

                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10 * scale,
                                        vertical: 4 * scale,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFEDE7F6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        t['specialty'] ?? "",
                                        style: TextStyle(
                                          fontSize: 12 * scale,
                                          color: Color(0xFF673AB7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 8 * scale),

                                    Icon(
                                      Icons.timelapse,
                                      size: 15,
                                      color: Colors.grey,
                                    ),

                                    SizedBox(width: 3 * scale),

                                    Text(
                                      "${t['experience'] ?? '0'} years",
                                      style: TextStyle(
                                        fontSize: 12 * scale,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 8 * scale),

                                SizedBox(
                                  width: 200 * scale,
                                  height: 34 * scale,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TrainerDetailScreen(trainer: t),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      "Contact",
                                      style: TextStyle(
                                        fontSize: 14 * scale,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BecomeTrainerScreen(),
            ),
          );
        },
        backgroundColor: Color(0xFFA353FF),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}