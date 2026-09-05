import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import '../settings_state.dart';

class ComparisonView extends StatefulWidget {
  const ComparisonView({super.key});

  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  String _filter = 'Weekly';
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseService().getAllTransactionsWithCategories();
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    // Grouping logic
    final now = DateTime.now();
    List<BarChartGroupData> barGroups = [];
    double maxY = 0;
    
    Widget bottomTitles(double value, TitleMeta meta) {
      String text = '';
      if (_filter == 'Weekly') {
        final d = now.subtract(Duration(days: 6 - value.toInt()));
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        text = days[d.weekday - 1];
      } else if (_filter == 'Monthly') {
        text = 'W${value.toInt() + 1}';
      } else {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        if (value >= 0 && value < 12) text = months[value.toInt()];
      }
      return SideTitleWidget(
        meta: meta,
        space: 8,
        child: Text(text, style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold)),
      );
    }

    if (_filter == 'Weekly') {
      List<double> totals = List.filled(7, 0.0);
      for (var t in _transactions) {
        final d = DateTime.fromMillisecondsSinceEpoch(t['date'] as int);
        final dayDiff = DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;
        if (dayDiff >= 0 && dayDiff < 7) {
          totals[6 - dayDiff] += (t['amount'] as double);
        }
      }
      for (int i = 0; i < 7; i++) {
        if (totals[i] > maxY) maxY = totals[i];
        barGroups.add(BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: totals[i], color: const Color(0xFF6366F1), width: 16, borderRadius: BorderRadius.circular(4))],
        ));
      }
    } else if (_filter == 'Monthly') {
      List<double> totals = List.filled(5, 0.0);
      for (var t in _transactions) {
        final d = DateTime.fromMillisecondsSinceEpoch(t['date'] as int);
        if (d.year == now.year && d.month == now.month) {
          int week = (d.day - 1) ~/ 7;
          if (week > 4) week = 4;
          totals[week] += (t['amount'] as double);
        }
      }
      for (int i = 0; i < 5; i++) {
        if (totals[i] > maxY) maxY = totals[i];
        barGroups.add(BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: totals[i], color: const Color(0xFF6366F1), width: 22, borderRadius: BorderRadius.circular(4))],
        ));
      }
    } else if (_filter == 'Yearly') {
      List<double> totals = List.filled(12, 0.0);
      for (var t in _transactions) {
        final d = DateTime.fromMillisecondsSinceEpoch(t['date'] as int);
        if (d.year == now.year) {
          totals[d.month - 1] += (t['amount'] as double);
        }
      }
      for (int i = 0; i < 12; i++) {
        if (totals[i] > maxY) maxY = totals[i];
        barGroups.add(BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: totals[i], color: const Color(0xFF6366F1), width: 12, borderRadius: BorderRadius.circular(4))],
        ));
      }
    }
    
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['Weekly', 'Monthly', 'Yearly'].map((f) {
              final isSelected = _filter == f;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(f),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6366F1),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : textColor),
                  onSelected: (val) {
                    if (val) setState(() => _filter = f);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text('Spending Comparison', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 24),
          
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark ? Colors.white : Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${settingsNotifier.value.currency}${rod.toY.toStringAsFixed(2)}',
                        TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: bottomTitles,
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == maxY || value == 0) return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: meta,
                          child: Text('${value ~/ 1}', style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 10)),
                        );
                      }
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: textColor.withOpacity(0.1), strokeWidth: 1),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
