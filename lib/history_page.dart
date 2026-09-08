import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/database_service.dart';
import 'settings_state.dart';
import 'widgets/comparison_view.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback? onTransactionChanged;
  const HistoryPage({super.key, this.onTransactionChanged});

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  final GlobalKey<LogsViewState> logsKey = GlobalKey<LogsViewState>();
  final GlobalKey<AnalyticsViewState> analyticsKey = GlobalKey<AnalyticsViewState>();
  final GlobalKey<ComparisonViewState> comparisonKey = GlobalKey<ComparisonViewState>();

  void loadData() {
    logsKey.currentState?.loadData();
    analyticsKey.currentState?.loadData();
    comparisonKey.currentState?.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('History & Analytics', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          bottom: TabBar(
            labelColor: const Color(0xFF6366F1),
            unselectedLabelColor: textColor.withValues(alpha: 0.5),
            indicatorColor: const Color(0xFF6366F1),
            tabs: const [
              Tab(text: 'Logs'),
              Tab(text: 'Analytics'),
              Tab(text: 'Comparison'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LogsView(key: logsKey, onTransactionChanged: widget.onTransactionChanged),
            AnalyticsView(key: analyticsKey),
            ComparisonView(key: comparisonKey),
          ],
        ),
      ),
    );
  }
}

class LogsView extends StatefulWidget {
  final VoidCallback? onTransactionChanged;
  const LogsView({super.key, this.onTransactionChanged});

  @override
  State<LogsView> createState() => LogsViewState();
}

class LogsViewState extends State<LogsView> {
  AnalyticsFilterType _filterType = AnalyticsFilterType.thisMonth;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int _selectedYear = DateTime.now().year;
  int _lastNDays = 14;
  DateTimeRange _customRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 14)),
    end: DateTime.now(),
  );

  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await DatabaseService().getAllTransactionsWithCategories();
    if (mounted) {
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    }
  }

  DateTimeRange? _getDateRange() {
    final now = DateTime.now();
    switch (_filterType) {
      case AnalyticsFilterType.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.lastMonth:
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.selectMonth:
        final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
        final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.last7Days:
        final start = DateTime(now.year, now.month, now.day - 6);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.last30Days:
        final start = DateTime(now.year, now.month, now.day - 29);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.lastNDays:
        final start = DateTime(now.year, now.month, now.day - (_lastNDays - 1));
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.thisYear:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.selectYear:
        final start = DateTime(_selectedYear, 1, 1);
        final end = DateTime(_selectedYear, 12, 31, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.customRange:
        final start = DateTime(_customRange.start.year, _customRange.start.month, _customRange.start.day);
        final end = DateTime(_customRange.end.year, _customRange.end.month, _customRange.end.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
    }
  }

  Future<void> _pickCustomMonth() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int pickedYear = _selectedMonth.year;
    int pickedMonth = _selectedMonth.month;

    final result = await showDialog<DateTime>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            const months = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            final textColor = isDark ? Colors.white : const Color(0xFF111827);

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.chevronLeft, color: textColor),
                    onPressed: () => setDialogState(() => pickedYear--),
                  ),
                  Text('$pickedYear', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  IconButton(
                    icon: Icon(LucideIcons.chevronRight, color: textColor),
                    onPressed: () => setDialogState(() => pickedYear++),
                  ),
                ],
              ),
              content: SizedBox(
                width: 280,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final isSelected = (index + 1) == pickedMonth;
                    return InkWell(
                      onTap: () => setDialogState(() => pickedMonth = index + 1),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          months[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                  onPressed: () => Navigator.of(ctx).pop(DateTime(pickedYear, pickedMonth)),
                  child: const Text('Select', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedMonth = result;
        _filterType = AnalyticsFilterType.selectMonth;
      });
    }
  }

  Future<void> _pickCustomDays() async {
    final controller = TextEditingController(text: '$_lastNDays');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Custom Number of Days', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. 14, 45, 90',
            labelText: 'Number of Days',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () {
              final n = int.tryParse(controller.text);
              if (n != null && n > 0) {
                Navigator.of(ctx).pop(n);
              }
            },
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _lastNDays = result;
        _filterType = AnalyticsFilterType.lastNDays;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final initialRange = _customRange;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF6366F1),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customRange = picked;
        _filterType = AnalyticsFilterType.customRange;
      });
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, Map<String, dynamic> t) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final amountStr = '${settingsNotifier.value.currency}${(t['amount'] as double).toStringAsFixed(2)}';
    final categoryName = t['subcategory_name'] ?? t['category_name'] ?? 'Expense';

    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Expense?', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        content: Text(
          'Are you sure you want to delete this $categoryName log of $amountStr?',
          style: TextStyle(color: textColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: textColor.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(Map<String, dynamic> t) async {
    final id = t['transaction_id'] as int?;
    if (id == null) return;
    await DatabaseService().deleteTransaction(id);
    await loadData();
    widget.onTransactionChanged?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
    }
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;

    final dateRange = _getDateRange();
    final List<Map<String, dynamic>> filtered;
    if (dateRange != null) {
      final startMs = dateRange.start.millisecondsSinceEpoch;
      final endMs = dateRange.end.millisecondsSinceEpoch;
      filtered = _transactions.where((t) {
        final d = t['date'] as int;
        return d >= startMs && d <= endMs;
      }).toList();
    } else {
      filtered = _transactions;
    }

    final double totalFilteredSpend = filtered.fold(0.0, (sum, item) => sum + (item['amount'] as double));

    final filterOptions = [
      {'label': 'This Month', 'type': AnalyticsFilterType.thisMonth},
      {'label': 'Last Month', 'type': AnalyticsFilterType.lastMonth},
      {'label': 'Specific Month', 'type': AnalyticsFilterType.selectMonth},
      {'label': 'Last 7 Days', 'type': AnalyticsFilterType.last7Days},
      {'label': 'Last 30 Days', 'type': AnalyticsFilterType.last30Days},
      {'label': 'Last $_lastNDays Days', 'type': AnalyticsFilterType.lastNDays},
      {'label': 'This Year', 'type': AnalyticsFilterType.thisYear},
      {'label': 'Specific Year', 'type': AnalyticsFilterType.selectYear},
      {'label': 'Custom Range', 'type': AnalyticsFilterType.customRange},
    ];

    final startStr = dateRange != null ? DateFormat('MMM d, yyyy').format(dateRange.start) : '';
    final endStr = dateRange != null ? DateFormat('MMM d, yyyy').format(dateRange.end) : '';

    // Group by day
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var t in filtered) {
      final date = DateTime.fromMillisecondsSinceEpoch(t['date'] as int);
      final key = DateFormat('yyyy-MM-dd').format(date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        // Top Filter Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filterOptions.map((opt) {
                    final type = opt['type'] as AnalyticsFilterType;
                    final isSelected = _filterType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(opt['label'] as String),
                        selected: isSelected,
                        selectedColor: const Color(0xFF6366F1),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _filterType = type);
                            if (type == AnalyticsFilterType.selectMonth) {
                              _pickCustomMonth();
                            } else if (type == AnalyticsFilterType.lastNDays) {
                              _pickCustomDays();
                            } else if (type == AnalyticsFilterType.customRange) {
                              _pickDateRange();
                            }
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Interactive Date Range Navigator Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_filterType == AnalyticsFilterType.selectMonth) ...[
                      IconButton(
                        icon: const Icon(LucideIcons.chevronLeft, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ] else if (_filterType == AnalyticsFilterType.selectYear) ...[
                      IconButton(
                        icon: const Icon(LucideIcons.chevronLeft, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedYear--;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],

                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_filterType == AnalyticsFilterType.selectMonth) {
                            _pickCustomMonth();
                          } else if (_filterType == AnalyticsFilterType.lastNDays) {
                            _pickCustomDays();
                          } else if (_filterType == AnalyticsFilterType.selectYear) {
                            _pickCustomMonth();
                          } else {
                            _pickDateRange();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF6366F1)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _filterType == AnalyticsFilterType.selectMonth
                                    ? DateFormat('MMMM yyyy').format(_selectedMonth)
                                    : (_filterType == AnalyticsFilterType.selectYear
                                        ? 'Year $_selectedYear'
                                        : '$startStr – $endStr'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(LucideIcons.edit3, size: 11, color: textColor.withValues(alpha: 0.4)),
                          ],
                        ),
                      ),
                    ),

                    if (_filterType == AnalyticsFilterType.selectMonth) ...[
                      IconButton(
                        icon: const Icon(LucideIcons.chevronRight, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ] else if (_filterType == AnalyticsFilterType.selectYear) ...[
                      IconButton(
                        icon: const Icon(LucideIcons.chevronRight, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedYear++;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              ),

              // Filter Summary Badge
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} log${filtered.length == 1 ? '' : 's'} found',
                      style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Period Total: ${settingsNotifier.value.currency}${totalFilteredSpend.toStringAsFixed(2)}',
                      style: const TextStyle(color: Color(0xFF6366F1), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Logs List or Empty State
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.receipt, size: 48, color: textColor.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        Text('No transactions found for this period', style: TextStyle(color: textColor.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 120),
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
                          padding: const EdgeInsets.only(top: 12, bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(headerText, style: TextStyle(fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.5))),
                              Text('${settingsNotifier.value.currency}${dayTotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.5))),
                            ],
                          ),
                        ),
                        ...items.map((t) {
                          final catColor = Color(int.parse(t['color_hex'] as String));
                          return Dismissible(
                            key: ValueKey('trans_${t['transaction_id']}'),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDelete(context, t),
                            onDismissed: (_) => _deleteTransaction(t),
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(LucideIcons.trash2, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: ListTile(
                                onTap: () async {
                                  final shouldDelete = await _confirmDelete(context, t);
                                  if (shouldDelete == true) {
                                    await _deleteTransaction(t);
                                  }
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(_getIconData(t['icon_code'] as String), color: catColor, size: 20),
                                ),
                                title: Text(t['subcategory_name'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                subtitle: t['note'] != null && (t['note'] as String).isNotEmpty
                                    ? Text(t['note'] as String, style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 12))
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '-${settingsNotifier.value.currency}${(t['amount'] as double).toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 16),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: Icon(LucideIcons.trash2, size: 18, color: textColor.withValues(alpha: 0.3)),
                                      onPressed: () async {
                                        final shouldDelete = await _confirmDelete(context, t);
                                        if (shouldDelete == true) {
                                          await _deleteTransaction(t);
                                        }
                                      },
                                      tooltip: 'Delete log',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

enum AnalyticsFilterType {
  thisMonth,
  lastMonth,
  selectMonth,
  last7Days,
  last30Days,
  lastNDays,
  thisYear,
  selectYear,
  customRange,
}

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => AnalyticsViewState();
}

class AnalyticsViewState extends State<AnalyticsView> {
  AnalyticsFilterType _filterType = AnalyticsFilterType.thisMonth;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int _selectedYear = DateTime.now().year;
  int _lastNDays = 14;
  DateTimeRange _customRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 14)),
    end: DateTime.now(),
  );

  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await DatabaseService().getAllTransactionsWithCategories();
    if (mounted) {
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    }
  }

  DateTimeRange _getDateRange() {
    final now = DateTime.now();
    switch (_filterType) {
      case AnalyticsFilterType.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.lastMonth:
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.selectMonth:
        final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
        final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.last7Days:
        final start = DateTime(now.year, now.month, now.day - 6);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.last30Days:
        final start = DateTime(now.year, now.month, now.day - 29);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.lastNDays:
        final start = DateTime(now.year, now.month, now.day - (_lastNDays - 1));
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.thisYear:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.selectYear:
        final start = DateTime(_selectedYear, 1, 1);
        final end = DateTime(_selectedYear, 12, 31, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case AnalyticsFilterType.customRange:
        final start = DateTime(_customRange.start.year, _customRange.start.month, _customRange.start.day);
        final end = DateTime(_customRange.end.year, _customRange.end.month, _customRange.end.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
    }
  }

  Future<void> _pickCustomMonth() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int pickedYear = _selectedMonth.year;
    int pickedMonth = _selectedMonth.month;

    final result = await showDialog<DateTime>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            const months = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            final textColor = isDark ? Colors.white : const Color(0xFF111827);

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.chevronLeft, color: textColor),
                    onPressed: () => setDialogState(() => pickedYear--),
                  ),
                  Text('$pickedYear', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  IconButton(
                    icon: Icon(LucideIcons.chevronRight, color: textColor),
                    onPressed: () => setDialogState(() => pickedYear++),
                  ),
                ],
              ),
              content: SizedBox(
                width: 280,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final isSelected = (index + 1) == pickedMonth;
                    return InkWell(
                      onTap: () => setDialogState(() => pickedMonth = index + 1),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          months[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                  onPressed: () => Navigator.of(ctx).pop(DateTime(pickedYear, pickedMonth)),
                  child: const Text('Select', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedMonth = result;
        _filterType = AnalyticsFilterType.selectMonth;
      });
    }
  }

  Future<void> _pickCustomDays() async {
    final controller = TextEditingController(text: '$_lastNDays');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Custom Number of Days', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. 14, 45, 90',
            labelText: 'Number of Days',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () {
              final n = int.tryParse(controller.text);
              if (n != null && n > 0) {
                Navigator.of(ctx).pop(n);
              }
            },
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _lastNDays = result;
        _filterType = AnalyticsFilterType.lastNDays;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final initialRange = _customRange;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF6366F1),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customRange = picked;
        _filterType = AnalyticsFilterType.customRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;

    final dateRange = _getDateRange();
    final startMs = dateRange.start.millisecondsSinceEpoch;
    final endMs = dateRange.end.millisecondsSinceEpoch;

    final filtered = _transactions.where((t) {
      final d = t['date'] as int;
      return d >= startMs && d <= endMs;
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

    // Day count in range
    final int daysCount = dateRange.end.difference(dateRange.start).inDays + 1;
    final double dailyAvg = daysCount > 0 ? (totalSpend / daysCount) : 0.0;

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

    final filterOptions = [
      {'label': 'This Month', 'type': AnalyticsFilterType.thisMonth},
      {'label': 'Last Month', 'type': AnalyticsFilterType.lastMonth},
      {'label': 'Specific Month', 'type': AnalyticsFilterType.selectMonth},
      {'label': 'Last 7 Days', 'type': AnalyticsFilterType.last7Days},
      {'label': 'Last 30 Days', 'type': AnalyticsFilterType.last30Days},
      {'label': 'Last $_lastNDays Days', 'type': AnalyticsFilterType.lastNDays},
      {'label': 'This Year', 'type': AnalyticsFilterType.thisYear},
      {'label': 'Specific Year', 'type': AnalyticsFilterType.selectYear},
      {'label': 'Custom Range', 'type': AnalyticsFilterType.customRange},
    ];

    final startStr = DateFormat('MMM d, yyyy').format(dateRange.start);
    final endStr = DateFormat('MMM d, yyyy').format(dateRange.end);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterOptions.map((opt) {
                final type = opt['type'] as AnalyticsFilterType;
                final isSelected = _filterType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(opt['label'] as String),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6366F1),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _filterType = type);
                        if (type == AnalyticsFilterType.selectMonth) {
                          _pickCustomMonth();
                        } else if (type == AnalyticsFilterType.lastNDays) {
                          _pickCustomDays();
                        } else if (type == AnalyticsFilterType.customRange) {
                          _pickDateRange();
                        }
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Interactive Date Range Selector / Navigator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // If Select Month or Select Year, show previous arrow
                if (_filterType == AnalyticsFilterType.selectMonth) ...[
                  IconButton(
                    icon: const Icon(LucideIcons.chevronLeft, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ] else if (_filterType == AnalyticsFilterType.selectYear) ...[
                  IconButton(
                    icon: const Icon(LucideIcons.chevronLeft, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedYear--;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],

                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_filterType == AnalyticsFilterType.selectMonth) {
                        _pickCustomMonth();
                      } else if (_filterType == AnalyticsFilterType.lastNDays) {
                        _pickCustomDays();
                      } else if (_filterType == AnalyticsFilterType.selectYear) {
                        _pickCustomMonth();
                      } else {
                        _pickDateRange();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF6366F1)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _filterType == AnalyticsFilterType.selectMonth
                                  ? DateFormat('MMMM yyyy').format(_selectedMonth)
                                  : (_filterType == AnalyticsFilterType.selectYear
                                      ? 'Year $_selectedYear'
                                      : '$startStr – $endStr'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(LucideIcons.edit3, size: 13, color: textColor.withValues(alpha: 0.4)),
                        ],
                      ),
                    ),
                  ),
                ),

                // Next Arrow
                if (_filterType == AnalyticsFilterType.selectMonth) ...[
                  IconButton(
                    icon: const Icon(LucideIcons.chevronRight, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ] else if (_filterType == AnalyticsFilterType.selectYear) ...[
                  IconButton(
                    icon: const Icon(LucideIcons.chevronRight, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedYear++;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Total Spend Card with Daily Avg & Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              children: [
                const Text('Total Spent', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(
                  '${settingsNotifier.value.currency}${totalSpend.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Daily Average', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '${settingsNotifier.value.currency}${dailyAvg.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 24, color: Colors.white24),
                      Column(
                        children: [
                          const Text('Transactions', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '${filtered.length}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 24, color: Colors.white24),
                      Column(
                        children: [
                          const Text('Days', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '$daysCount',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 28),
          Text('Spending Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 14),
          
          if (totalSpend == 0)
             Center(
               child: Padding(
                 padding: const EdgeInsets.all(32.0),
                 child: Column(
                   children: [
                     Icon(LucideIcons.pieChart, size: 48, color: textColor.withValues(alpha: 0.2)),
                     const SizedBox(height: 12),
                     Text('No expenses recorded for this period', style: TextStyle(color: textColor.withValues(alpha: 0.5))),
                   ],
                 ),
               ),
             )
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
                      backgroundColor: color.withValues(alpha: 0.2),
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
