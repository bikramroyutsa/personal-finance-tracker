import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'settings_state.dart';
import 'services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

// Keeping state public so MainScreen can call reload
class HomePageState extends State<HomePage> {
  DateTime _currentDate = DateTime.now();
  
  double _todaySpend = 0.0;
  double _monthSpend = 0.0;
  List<Map<String, dynamic>> _breakdownData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final startOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final endOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0, 23, 59, 59, 999);
    
    final startOfDay = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    final endOfDay = DateTime(_currentDate.year, _currentDate.month, _currentDate.day, 23, 59, 59, 999);

    final todaySpend = await DatabaseService().getTotalSpendForDateRange(startOfDay, endOfDay);
    final monthSpend = await DatabaseService().getTotalSpendForDateRange(startOfMonth, endOfMonth);
    final breakdown = await DatabaseService().getCategoryBreakdown(_currentDate);
    
    if (mounted) {
      setState(() {
        _todaySpend = todaySpend;
        _monthSpend = monthSpend;
        _breakdownData = breakdown;
      });
    }
  }

  void _changeDay(int days) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: days));
    });
    loadData();
  }

  void _jumpToToday() {
    setState(() {
      _currentDate = DateTime.now();
    });
    loadData();
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

  Widget _buildSpendCard(String title, double amount, double maxAmount, String currency, bool isDark) {
    final double ratio = maxAmount > 0 ? (amount / maxAmount) : 0;
    
    List<Color> gradientColors;
    if (ratio < 0.8) {
      gradientColors = isDark 
          ? [const Color(0xFF059669), const Color(0xFF047857)]
          : [const Color(0xFF34D399), const Color(0xFF10B981)];
    } else if (ratio <= 1.0) {
      gradientColors = isDark 
          ? [const Color(0xFFD97706), const Color(0xFFB45309)]
          : [const Color(0xFFFBBF24), const Color(0xFFF59E0B)];
    } else {
      gradientColors = isDark 
          ? [const Color(0xFFDC2626), const Color(0xFFB91C1C)]
          : [const Color(0xFFF87171), const Color(0xFFEF4444)];
    }

    final formattedAmount = amount.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(isDark ? 0.4 : 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$currency$formattedAmount',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDate = DateFormat('MMM d, yyyy').format(_currentDate);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;

    final now = DateTime.now();
    final isNotToday = _currentDate.year != now.year || _currentDate.month != now.month || _currentDate.day != now.day;

    return ValueListenableBuilder<UserSettings>(
      valueListenable: settingsNotifier,
      builder: (context, settings, child) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Top Bar & Back to Today Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(LucideIcons.chevronLeft, color: textColor),
                          onPressed: () => _changeDay(-1),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.chevronRight, color: textColor),
                          onPressed: () => _changeDay(1),
                        ),
                      ],
                    ),
                    if (isNotToday)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton.icon(
                          onPressed: _jumpToToday,
                          icon: const Icon(LucideIcons.calendarClock, size: 16, color: Color(0xFF6366F1)),
                          label: const Text('Back to Today', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Side by Side Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSpendCard(
                        'Today', 
                        _todaySpend, 
                        settings.dailyMax, 
                        settings.currency, 
                        isDark
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSpendCard(
                        'This Month', 
                        _monthSpend, 
                        settings.monthlyMax, 
                        settings.currency, 
                        isDark
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Breakdown',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (_breakdownData.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Center(
                    child: Text(
                      'No spending for this date.',
                      style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 16),
                    ),
                  ),
                )
              else
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _breakdownData.length,
                  itemBuilder: (context, index) {
                    final item = _breakdownData[index];
                    final catColor = Color(int.parse(item['color_hex']));
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(isDark ? 0.3 : 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getIconData(item['icon_code']),
                                color: catColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item['name'] as String,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Text(
                              '${settings.currency}${(item['total'] as double).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
