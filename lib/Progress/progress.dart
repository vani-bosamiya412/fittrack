import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProgressScreen extends StatefulWidget {
  final int steps;
  final double calories;
  final int activeMinutes;
  final int workouts;

  const ProgressScreen({
    super.key,
    required this.steps,
    required this.calories,
    required this.activeMinutes,
    required this.workouts,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  static const String _urlHistory =
      "https://prakrutitech.xyz/vani/view_history.php";

  bool showWeek = true;
  bool loading = true;
  String? errorMessage;

  List<double> stepsHistory = [];
  List<double> caloriesHistory = [];
  List<double> activeHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryFromApi();
  }

  Future<void> _loadHistoryFromApi() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('user_id') ?? 0;
      if (userId <= 0) throw Exception("User not logged in.");

      final url = Uri.parse("$_urlHistory?user_id=$userId");
      final resp = await http.get(url).timeout(Duration(seconds: 10));
      if (resp.statusCode != 200) {
        throw Exception("Server error ${resp.statusCode}");
      }

      final List data = json.decode(resp.body) as List;

      Map<String, Map<String, double>> byDate = {};

      for (final row in data) {
        if (row == null) continue;
        final dateRaw = (row['activity_date'] ?? '').toString();
        if (dateRaw.isEmpty) continue;
        final dateKey = dateRaw.split(' ').first.trim();
        byDate[dateKey] = {
          'steps': _safeDoubleFrom(row['steps']),
          'calories': _safeDoubleFrom(row['calories']),
          'active': _safeDoubleFrom(row['duration']),
        };
      }

      final week = _buildWeeklySeries(byDate);
      final month = _buildMonthlySeries(byDate);

      setState(() {
        stepsHistory = showWeek ? week['steps']! : month['steps']!;
        caloriesHistory = showWeek ? week['calories']! : month['calories']!;
        activeHistory = showWeek ? week['active']! : month['active']!;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  Map<String, List<double>> _buildWeeklySeries(
    Map<String, Map<String, double>> byDate,
  ) {
    List<double> steps = List.filled(7, 0);
    List<double> calories = List.filled(7, 0);
    List<double> active = List.filled(7, 0);

    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final key = _dateKey(date);
      if (byDate.containsKey(key)) {
        steps[i] = byDate[key]!['steps'] ?? 0;
        calories[i] = byDate[key]!['calories'] ?? 0;
        active[i] = byDate[key]!['active'] ?? 0;
      } else {
        steps[i] = 0;
        calories[i] = 0;
        active[i] = 0;
      }
    }

    return {"steps": steps, "calories": calories, "active": active};
  }

  Map<String, List<double>> _buildMonthlySeries(
    Map<String, Map<String, double>> byDate,
  ) {
    List<double> steps = [];
    List<double> calories = [];
    List<double> active = [];

    final today = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key = _dateKey(date);

      steps.add((byDate[key]?['steps']) ?? 0);
      calories.add((byDate[key]?['calories']) ?? 0);
      active.add((byDate[key]?['active']) ?? 0);
    }

    return {"steps": steps, "calories": calories, "active": active};
  }

  double _safeDoubleFrom(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  Future<void> _onRefresh() async {
    await _loadHistoryFromApi();
  }

  double _computeMaxY(List<double> values) {
    if (values.isEmpty) return 10;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final scaled = maxVal * 1.2;
    return scaled < 10 ? 10 : scaled;
  }

  List<BarChartGroupData> _makeBarGroups(
    List<double> values, {
    required bool isMonth,
  }) {
    final barWidth = isMonth ? 8.0 : 16.0;
    return List.generate(values.length, (i) {
      final v = values[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: v,
            width: barWidth,
            borderRadius: BorderRadius.circular(6),
            color: Color(0xFFA353FF),
          ),
        ],
      );
    });
  }

  List<FlSpot> _makeSpots(List<double> values) {
    return List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));
  }

  String _xLabel(int index, int total) {
    if (showWeek) {
      const weekNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      return (index >= 0 && index < weekNames.length) ? weekNames[index] : "";
    } else {
      final today = DateTime.now();
      final date = today.subtract(Duration(days: total - 1 - index));

      if (date.day % 5 != 0) return "";

      return date.day.toString();
    }
  }

  Widget _topToggle(double w) {
    return Container(
      padding: EdgeInsets.all(w * 0.015),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(w * 0.08),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!showWeek) {
                  setState(() {
                    showWeek = true;
                  });
                  _loadHistoryFromApi();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: w * 0.03),
                decoration: BoxDecoration(
                  color: showWeek ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(w * 0.08),
                ),
                alignment: Alignment.center,
                child: Text(
                  "This Week",
                  style: TextStyle(
                    color: showWeek ? Colors.black : Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: w * 0.04,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: w * 0.02),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (showWeek) {
                  setState(() {
                    showWeek = false;
                  });
                  _loadHistoryFromApi();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: w * 0.03),
                decoration: BoxDecoration(
                  color: !showWeek ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(w * 0.08),
                ),
                alignment: Alignment.center,
                child: Text(
                  "This Month",
                  style: TextStyle(
                    color: !showWeek ? Colors.black : Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: w * 0.04,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox({
    required IconData icon,
    required String title,
    required String value,
    required double w,
  }) {
    return Container(
      padding: EdgeInsets.all(w * 0.035),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(w * 0.03),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFFA353FF), size: w * 0.07),
          SizedBox(height: w * 0.02),
          Text(
            value,
            style: TextStyle(fontSize: w * 0.07, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: w * 0.01),
          Text(
            title,
            style: TextStyle(color: Colors.black54, fontSize: w * 0.035),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsChart(List<double> values, double h, double w) {
    if (values.isEmpty) return _emptyChartPlaceholder("No steps data", h);
    final maxY = _computeMaxY(values);
    final isMonth = !showWeek;
    final groups = _makeBarGroups(values, isMonth: isMonth);
    return SizedBox(
      height: h * 0.28,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barGroups: groups,
          gridData: FlGridData(show: true, drawHorizontalLine: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: isMonth ? 4 : 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= values.length) {
                    return SizedBox.shrink();
                  }
                  final label = _xLabel(idx, values.length);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Text(label, style: TextStyle(fontSize: w * 0.025)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: w * 0.12),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesChart(List<double> values, double h, double w) {
    if (values.isEmpty) return _emptyChartPlaceholder("No calories data", h);
    final maxY = _computeMaxY(values);
    final isMonth = !showWeek;
    final spots = _makeSpots(values);
    return SizedBox(
      height: h * 0.28,
      child: LineChart(
        LineChartData(
          maxY: maxY,
          minY: 0,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: isMonth ? 4 : 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= values.length) {
                    return SizedBox.shrink();
                  }
                  final label = _xLabel(idx, values.length);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Text(label, style: TextStyle(fontSize: w * 0.025)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: w * 0.12),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              dotData: FlDotData(show: true),
              color: Color(0xFFA353FF),
              belowBarData: BarAreaData(show: false),
              barWidth: w * 0.01,
            ),
          ],
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildActiveChart(List<double> values, double h, double w) {
    if (values.isEmpty) {
      return _emptyChartPlaceholder("No active minutes data", h);
    }
    final maxY = _computeMaxY(values);
    final isMonth = !showWeek;
    final groups = _makeBarGroups(values, isMonth: isMonth);
    return SizedBox(
      height: h * 0.28,
      child: BarChart(
        BarChartData(
          barGroups: groups,
          maxY: maxY,
          minY: 0,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: isMonth ? 4 : 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= values.length) {
                    return SizedBox.shrink();
                  }
                  final label = _xLabel(idx, values.length);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Text(label, style: TextStyle(fontSize: w * 0.025)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: w * 0.12),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _emptyChartPlaceholder(String label, double h) {
    return SizedBox(
      height: h * 0.28,
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: Colors.black38, fontSize: h * 0.018),
        ),
      ),
    );
  }

  Widget _responsiveTitle(String text, double w) {
    return Text(
      text,
      style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.w700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final h = mq.height;
    final w = mq.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          "Progress",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: w * 0.05,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Color(0xFFA353FF),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(w * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topToggle(w),
              SizedBox(height: h * 0.02),
              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      icon: Icons.directions_walk,
                      title: "Total Steps",
                      value: widget.steps.toString(),
                      w: w,
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: _statBox(
                      icon: Icons.local_fire_department,
                      title: "Calories",
                      value: widget.calories.toStringAsFixed(0),
                      w: w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.015),
              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      icon: Icons.watch_later_outlined,
                      title: "Active Time",
                      value: "${widget.activeMinutes} min",
                      w: w,
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: _statBox(
                      icon: Icons.fitness_center,
                      title: "Workouts",
                      value: widget.workouts.toString(),
                      w: w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.025),
              if (loading)
                Column(
                  children: [
                    SizedBox(height: h * 0.04),
                    Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFA353FF),
                      ),
                    ),
                  ],
                )
              else if (errorMessage != null)
                Column(
                  children: [
                    SizedBox(height: h * 0.04),
                    Center(
                      child: Text(
                        "Error: $errorMessage",
                        style: TextStyle(color: Colors.red, fontSize: w * 0.04),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    SizedBox(height: h * 0.01),
                    Container(
                      padding: EdgeInsets.all(w * 0.035),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(w * 0.03),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _responsiveTitle("Daily Steps", w),
                          SizedBox(height: h * 0.015),
                          _buildStepsChart(stepsHistory, h, w),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.02),
                    Container(
                      padding: EdgeInsets.all(w * 0.035),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(w * 0.03),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _responsiveTitle("Calories Burned", w),
                          SizedBox(height: h * 0.015),
                          _buildCaloriesChart(caloriesHistory, h, w),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.02),
                    Container(
                      padding: EdgeInsets.all(w * 0.035),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(w * 0.03),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _responsiveTitle("Active Minutes", w),
                          SizedBox(height: h * 0.015),
                          _buildActiveChart(activeHistory, h, w),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.04),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}