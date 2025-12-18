import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'nutrition_detail_screen.dart';

class Nutrition {
  final int id;
  String title;
  String description;
  int calories;
  int protein;
  int carbs;
  int fat;
  int durationDays;
  int nutritionistId;

  Nutrition({
    required this.id,
    required this.title,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.durationDays,
    required this.nutritionistId,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      calories: int.tryParse(json['calories'].toString()) ?? 0,
      protein: int.tryParse(json['protein'].toString()) ?? 0,
      carbs: int.tryParse(json['carbs'].toString()) ?? 0,
      fat: int.tryParse(json['fat'].toString()) ?? 0,
      durationDays: int.tryParse(json['duration_days'].toString()) ?? 0,
      nutritionistId: int.tryParse(json['nutritionist_id'].toString()) ?? 0,
    );
  }
}

class NutritionManagementScreen extends StatefulWidget {
  const NutritionManagementScreen({super.key});

  @override
  State<NutritionManagementScreen> createState() =>
      _NutritionManagementScreenState();
}

class _NutritionManagementScreenState extends State<NutritionManagementScreen> {
  List<Nutrition> nutritionList = [];
  bool isLoading = true;

  final String viewApiUrl = "https://prakrutitech.xyz/vani/view_nutrition.php";

  @override
  void initState() {
    super.initState();
    fetchNutritionPlans();
  }

  Future<void> fetchNutritionPlans() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(viewApiUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          nutritionList = data.map((item) => Nutrition.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load nutrition plans")),
        );
      }
    } catch (_) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load nutrition plans")),
      );
    }
  }

  Widget nutrientRow(String label, int value, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "$value g",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17 * scale,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          label,
          style: TextStyle(fontSize: 14 * scale, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 390;

    return Scaffold(
      backgroundColor: Color(0xfff4f6f9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          "Nutrition Plans",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : RefreshIndicator(
              onRefresh: fetchNutritionPlans,
              color: Color(0xFFA353FF),
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.all(16 * scale),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * scale,
                      vertical: 26 * scale,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff00c853), Color(0xff009624)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20 * scale),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fuel Your Fitness",
                          style: TextStyle(
                            fontSize: 24 * scale,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          "Choose a nutrition plan that aligns with your fitness goals",
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                    itemCount: nutritionList.length,
                    itemBuilder: (context, index) {
                      final plan = nutritionList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NutritionDetailScreen(nutritionId: plan.id),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 18 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16 * scale),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withValues(alpha: 0.05),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(18 * scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.title,
                                  style: TextStyle(
                                    fontSize: 22 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8 * scale,),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: plan.title.contains("Weight")
                                        ? Colors.green.shade100
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    plan.title.contains("Weight")
                                        ? "Weight Loss"
                                        : plan.title.contains("Muscle")
                                        ? "Muscle Building"
                                        : "Maintenance",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12 * scale),

                                Text(
                                  plan.description,
                                  style: TextStyle(
                                    fontSize: 17 * scale,
                                    color: Colors.black87,
                                    height: 1.35,
                                  ),
                                ),
                                SizedBox(height: 20 * scale),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    nutrientRow(
                                      "Calories",
                                      plan.calories,
                                      scale,
                                    ),
                                    nutrientRow("Protein", plan.protein, scale),
                                    nutrientRow("Carbs", plan.carbs, scale),
                                    nutrientRow("Fats", plan.fat, scale),
                                  ],
                                ),

                                SizedBox(height: 14 * scale),
                                Container(
                                  height: 1,
                                  color: Colors.grey.shade300,
                                ),
                                SizedBox(height: 10 * scale),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_fire_department,
                                          size: 20 * scale,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(width: 5 * scale),
                                        Text(
                                          "${plan.durationDays} meals/day",
                                          style: TextStyle(
                                            fontSize: 16 * scale,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "View Details →",
                                      style: TextStyle(
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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