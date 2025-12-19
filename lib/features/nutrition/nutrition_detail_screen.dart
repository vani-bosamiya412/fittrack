import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NutritionDetailScreen extends StatefulWidget {
  final int nutritionId;

  const NutritionDetailScreen({super.key, required this.nutritionId});

  @override
  State<NutritionDetailScreen> createState() => _NutritionDetailScreenState();
}

class _NutritionDetailScreenState extends State<NutritionDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? nutrition;
  final String apiUrl = "https://prakrutitech.xyz/vani/view_nutrition.php";

  @override
  void initState() {
    super.initState();
    fetchNutritionDetail();
  }

  Future<void> fetchNutritionDetail() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          final selected = data.firstWhere(
            (item) => item['id'].toString() == widget.nutritionId.toString(),
            orElse: () => {},
          );
          if (selected.isNotEmpty) {
            setState(() {
              nutrition = selected;
              isLoading = false;
            });
          } else {
            setState(() => isLoading = false);
          }
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 390;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          nutrition?['title'] ?? "",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : nutrition == null
          ? Center(child: Text("No data found"))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(18 * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18 * scale),
                      gradient: LinearGradient(
                        colors: [Color(0xff00c853), Color(0xff009624)],
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26 * scale,
                          backgroundColor: Colors.white.withValues(alpha: .2),
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 28 * scale,
                          ),
                        ),
                        SizedBox(width: 14 * scale),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nutrition!['title'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              Text(
                                nutrition!['title'].contains("Muscle")
                                    ? "Muscle Building"
                                    : nutrition!['title'].contains("Weight")
                                    ? "Weight Loss"
                                    : "Maintenance",
                                style: TextStyle(
                                  fontSize: 14 * scale,
                                  color: Colors.white.withValues(alpha: .9),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 20 * scale),

                  _sectionCard(
                    title: "About This Plan",
                    child: Text(
                      nutrition!['description'],
                      style: TextStyle(
                        fontSize: 15 * scale,
                        color: Colors.black,
                      ),
                    ),
                    scale: scale,
                  ),

                  SizedBox(height: 20 * scale),

                  _sectionCard(
                    title: "Daily Target",
                    child: Column(
                      children: [
                        SizedBox(height: 8 * scale),
                        Text(
                          "${nutrition!['calories']}",
                          style: TextStyle(
                            fontSize: 34 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          ),
                        ),
                        Text(
                          "Calories per day",
                          style: TextStyle(
                            fontSize: 14 * scale,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: 18 * scale),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _circleStat(
                              "${nutrition!['protein']}g",
                              "Protein",
                              Colors.blue.shade100,
                              scale,
                            ),
                            _circleStat(
                              "${nutrition!['carbs']}g",
                              "Carbs",
                              Colors.orange.shade100,
                              scale,
                            ),
                            _circleStat(
                              "${nutrition!['fat']}g",
                              "Fats",
                              Colors.yellow.shade200,
                              scale,
                            ),
                          ],
                        ),
                      ],
                    ),
                    scale: scale,
                  ),

                  SizedBox(height: 20 * scale),

                  _sectionCard(
                    title: "Macro Breakdown",
                    child: Column(
                      children: [
                        _macroBar(
                          "Protein",
                          nutrition!['protein'],
                          Colors.blue,
                          scale,
                        ),
                        _macroBar(
                          "Carbs",
                          nutrition!['carbs'],
                          Colors.red,
                          scale,
                        ),
                        _macroBar(
                          "Fats",
                          nutrition!['fat'],
                          Colors.orange,
                          scale,
                        ),
                      ],
                    ),
                    scale: scale,
                  ),

                  SizedBox(height: 20 * scale),

                  _sectionCard(
                    title: "Meal Structure",
                    child: Row(
                      children: [
                        Icon(
                          Icons.fastfood_outlined,
                          color: Colors.green,
                          size: 28 * scale,
                        ),
                        SizedBox(width: 10 * scale),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${nutrition!['duration_days']} meals per day",
                              style: TextStyle(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w600,
                                color: Colors.black
                              ),
                            ),
                            Text(
                              "Evenly distributed throughout the day",
                              style: TextStyle(
                                fontSize: 13.5 * scale,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    scale: scale,
                  ),

                  SizedBox(height: 30 * scale),
                ],
              ),
            ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 17 * scale, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          SizedBox(height: 12 * scale),
          child,
        ],
      ),
    );
  }

  Widget _circleStat(String value, String label, Color color, double scale) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14 * scale),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Text(
            value,
            style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          label,
          style: TextStyle(fontSize: 14 * scale, color: Colors.black),
        ),
      ],
    );
  }

  Widget _macroBar(String label, dynamic value, Color color, double scale) {
    final grams = int.tryParse(value.toString()) ?? 0;
    final calories = int.tryParse(nutrition!['calories'].toString()) ?? 1;

    int macroCalories = 0;
    if (label == "Protein") macroCalories = grams * 4;
    if (label == "Carbs") macroCalories = grams * 4;
    if (label == "Fats") macroCalories = grams * 9;

    final percentage = (macroCalories / calories) * 100;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7 * scale),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 14 * scale, color: Colors.black)),
              Text("${percentage.toStringAsFixed(0)}%", style: TextStyle(fontSize: 14 * scale, color: Colors.black)),
            ],
          ),
          SizedBox(height: 6 * scale),
          Container(
            height: 6 * scale,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(30 * scale),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (percentage / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(30 * scale),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}