import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:currency_picker/currency_picker.dart';
import 'settings_state.dart';
import 'main.dart'; // for MainScreen
import 'manage_categories_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  String _currency = '\$';
  final TextEditingController _dailyController = TextEditingController(text: '150');
  final TextEditingController _monthlyController = TextEditingController(text: '3000');

  @override
  void dispose() {
    _pageController.dispose();
    _dailyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _finishOnboarding() {
    final daily = double.tryParse(_dailyController.text) ?? 150.0;
    final monthly = double.tryParse(_monthlyController.text) ?? 3000.0;
    
    settingsNotifier.value = settingsNotifier.value.copyWith(
      currency: _currency,
      dailyMax: daily,
      monthlyMax: monthly,
      isFirstTime: false,
    );
    
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  Widget _buildWelcomePage(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.wallet, size: 100, color: const Color(0xFF6366F1)),
          const SizedBox(height: 48),
          Text(
            'Welcome to\nFinance Tracker',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Let\'s get you set up so you can start managing your money effortlessly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyPage(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.banknote, size: 80, color: const Color(0xFF10B981)),
          const SizedBox(height: 32),
          Text('Select Your Currency', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          Text(
            'What currency do you primarily use for your expenses?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 15, offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListTile(
              leading: Icon(LucideIcons.coins, color: textColor),
              title: Text('Currency', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_currency, style: TextStyle(color: const Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(width: 8),
                  Icon(LucideIcons.chevronRight, color: textColor.withOpacity(0.5)),
                ],
              ),
              onTap: () {
                showCurrencyPicker(
                  context: context,
                  showFlag: true,
                  showCurrencyName: true,
                  showCurrencyCode: true,
                  theme: CurrencyPickerThemeData(
                    backgroundColor: cardBg,
                    titleTextStyle: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                    subtitleTextStyle: TextStyle(color: textColor.withOpacity(0.7)),
                  ),
                  onSelect: (Currency currency) {
                    setState(() {
                      _currency = currency.symbol;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetsPage(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.target, size: 80, color: const Color(0xFFF59E0B)),
          const SizedBox(height: 32),
          Text('Set Spending Limits', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          Text(
            'Set your goals for how much you want to spend at most daily and monthly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 15, offset: const Offset(0, 4),
                )
              ],
            ),
            child: TextField(
              controller: _dailyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                icon: Icon(LucideIcons.calendar, color: textColor.withOpacity(0.7)),
                labelText: 'Daily Limit',
                labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                border: InputBorder.none,
                prefixText: _currency,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 15, offset: const Offset(0, 4),
                )
              ],
            ),
            child: TextField(
              controller: _monthlyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                icon: Icon(LucideIcons.calendarDays, color: textColor.withOpacity(0.7)),
                labelText: 'Monthly Limit',
                labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                border: InputBorder.none,
                prefixText: _currency,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesPage(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.tags, size: 80, color: const Color(0xFF8B5CF6)),
          const SizedBox(height: 32),
          Text('Configure Categories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          Text(
            'We have prepared some default categories for you. You can review and edit them now, or do it later in Settings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5)),
            ),
            child: ListTile(
              leading: Icon(LucideIcons.settings2, color: const Color(0xFF6366F1)),
              title: const Text('Manage Categories', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
              trailing: Icon(LucideIcons.chevronRight, color: const Color(0xFF6366F1).withOpacity(0.5)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageCategoriesPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Force using buttons
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(isDark),
                  _buildCurrencyPage(isDark),
                  _buildBudgetsPage(isDark),
                  _buildCategoriesPage(isDark),
                ],
              ),
            ),
            
            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button (hidden on first page)
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text('Back', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 16)),
                    )
                  else
                    const SizedBox(width: 80), // spacer to keep Next button aligned right
                    
                  // Indicators
                  Row(
                    children: List.generate(4, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? const Color(0xFF6366F1) : textColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  
                  // Next / Finish Button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == 3 ? 'Finish' : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
