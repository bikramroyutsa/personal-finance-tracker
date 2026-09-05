import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/database_service.dart';
import 'settings_state.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('History & Analytics', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          bottom: TabBar(
            labelColor: const Color(0xFF6366F1),
            unselectedLabelColor: textColor.withOpacity(0.5),
            indicatorColor: const Color(0xFF6366F1),
            tabs: const [
              Tab(text: 'Logs'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LogsView(),
            _AnalyticsView(),
          ],
        ),
      ),
    );
  }
}

class _LogsView extends StatefulWidget {
  const _LogsView();

  @override
  State<_LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends State<_LogsView> {
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
  
  IconData _getIconData(String iconCode) {
    switch (iconCode) {
      case 'shoppingBag': return LucideIcons.shoppingBag;
      case 'car': return LucideIcons.car;
      case 'home': return LucideIcons.home;
      case 'monitor': return LucideIcons.monitor;
      case 'heart': return LucideIcons.heart;
      case 'coffee': return LucideIcons.coffee;
      case 'plane': return LucideIcons.plane;
      case 'music': return LucideIcons.music;
      case 'book': return LucideIcons.book;
      case 'briefcase': return LucideIcons.briefcase;
      case 'building': return LucideIcons.building;
      case 'bus': return LucideIcons.bus;
      case 'camera': return LucideIcons.camera;
      case 'dumbbell': return LucideIcons.dumbbell;
      case 'flame': return LucideIcons.flame;
      case 'gamepad2': return LucideIcons.gamepad2;
      case 'globe': return LucideIcons.globe;
      case 'graduationCap': return LucideIcons.graduationCap;
      case 'key': return LucideIcons.key;
      case 'leaf': return LucideIcons.leaf;
      case 'lightbulb': return LucideIcons.lightbulb;
      case 'palette': return LucideIcons.palette;
      case 'penTool': return LucideIcons.penTool;
      case 'pill': return LucideIcons.pill;
      case 'scissors': return LucideIcons.scissors;
      case 'shirt': return LucideIcons.shirt;
      case 'smartphone': return LucideIcons.smartphone;
      case 'truck': return LucideIcons.truck;
      case 'tv': return LucideIcons.tv;
      case 'umbrella': return LucideIcons.umbrella;
      case 'utensils': return LucideIcons.utensils;
      case 'zap': return LucideIcons.zap;
      default: return LucideIcons.circleDollarSign;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_transactions.isEmpty) return const Center(child: Text('No transactions found.'));

    // Group by day
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var t in _transactions) {
      final date = DateTime.fromMillisecondsSinceEpoch(t['date'] as int);
      final key = DateFormat('yyyy-MM-dd').format(date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 120),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final items = grouped[key]!;
        final date = DateTime.parse(key);
        
        String headerText = DateFormat('MMM d, yyyy').format(date);
        final today = DateTime.now();
        if (date.year == today.year && date.month == today.month && date.day == today.day) {
          headerText = 'Today';
        } else if (date.year == today.year && date.month == today.month && date.day == today.day - 1) {
          headerText = 'Yesterday';
        }
        
        final double dayTotal = items.fold(0.0, (sum, item) => sum + (item['amount'] as double));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(headerText, style: TextStyle(fontWeight: FontWeight.bold, color: textColor.withOpacity(0.5))),
                  Text('${settingsNotifier.value.currency}${dayTotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor.withOpacity(0.5))),
                ],
              ),
            ),
            ...items.map((t) {
              final catColor = Color(int.parse(t['color_hex'] as String));
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIconData(t['icon_code'] as String), color: catColor, size: 20),
                  ),
                  title: Text(t['subcategory_name'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  subtitle: t['note'] != null && (t['note'] as String).isNotEmpty
                      ? Text(t['note'] as String, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12))
                      : null,
                  trailing: Text(
                    '-${settingsNotifier.value.currency}${(t['amount'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 16),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class _AnalyticsView extends StatefulWidget {
  const _AnalyticsView();

  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView> {
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
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;

    // Filter transactions based on selected range
    final now = DateTime.now();
    DateTime cutoff;
    if (_filter == 'Weekly') {
      cutoff = now.subtract(const Duration(days: 7));
    } else if (_filter == 'Monthly') {
      cutoff = DateTime(now.year, now.month - 1, now.day);
    } else {
      cutoff = DateTime(now.year - 1, now.month, now.day);
    }
    
    final filtered = _transactions.where((t) {
      final d = DateTime.fromMillisecondsSinceEpoch(t['date'] as int);
      return d.isAfter(cutoff);
    }).toList();

    // Categorical breakdown
    final Map<String, double> catTotals = {};
    final Map<String, Color> catColors = {};
    for (var t in filtered) {
      final cat = t['category_name'] as String;
      final color = Color(int.parse(t['color_hex'] as String));
      catTotals[cat] = (catTotals[cat] ?? 0) + (t['amount'] as double);
      catColors[cat] = color;
    }
    
    final sortedCats = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final double totalSpend = catTotals.values.fold(0.0, (a, b) => a + b);

    List<PieChartSectionData> pieSections = [];
    if (totalSpend > 0) {
      pieSections = sortedCats.map((e) {
        final percentage = (e.value / totalSpend) * 100;
        return PieChartSectionData(
          color: catColors[e.key],
          value: e.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 60,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        );
      }).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
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
          const SizedBox(height: 24),
          
          // Total Spend Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text('Total Spent', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  '${settingsNotifier.value.currency}${totalSpend.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text('Spending Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          
          if (totalSpend == 0)
             const Center(child: Padding(
               padding: EdgeInsets.all(32.0),
               child: Text('No data for this period'),
             ))
          else ...[
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...sortedCats.map((e) {
              final percentage = (e.value / totalSpend);
              final color = catColors[e.key]!;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(e.key, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                          ],
                        ),
                        Text('${settingsNotifier.value.currency}${e.value.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              );
            }).toList()
          ],
        ],
      ),
    );
  }
}
