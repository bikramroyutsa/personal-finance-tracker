import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'debts_page.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/add_debt_sheet.dart';
import 'settings_state.dart';
import 'onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSettings();
  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Finance Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF9FAFB),
            textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF111827),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            useMaterial3: true,
          ),
          themeMode: currentMode,
          home: settingsNotifier.value.isFirstTime 
              ? const OnboardingPage() 
              : const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Default to Home
  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();
  final GlobalKey<DebtsPageState> _debtsKey = GlobalKey<DebtsPageState>();
  
  // Draggable FAB position
  Offset? _fabPosition;
  
  final QuickActions quickActions = const QuickActions();

  @override
  void initState() {
    super.initState();
    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'action_add_transaction') {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _currentIndex = 1; // Go to home just in case
          });
          _openAddTransactionSheet();
        });
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_add_transaction',
        localizedTitle: 'Add Transaction',
        icon: 'icon_add',
      ),
    ]);
    
    try {
      if (Platform.isAndroid) {
        FlutterOverlayWindow.overlayListener.listen((event) {
          if (event == 'refresh_transactions') {
            _homeKey.currentState?.loadData();
          }
        });
      }
    } catch (e) {
      // Ignore if not supported
    }
  }
  
  void _openAddTransactionSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_currentIndex == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => AddDebtSheet(
          isDark: isDark,
          onDebtAdded: () {
            _debtsKey.currentState?.loadData();
          },
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => AddTransactionSheet(
          isDark: isDark,
          onTransactionAdded: () {
            // Trigger a refresh on the home page when a transaction is added
            _homeKey.currentState?.loadData();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final activeColor = const Color(0xFF6366F1);
    final inactiveColor = isDark ? Colors.white54 : Colors.black45;
    
    final screenSize = MediaQuery.of(context).size;

    final scaffold = Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HistoryPage(),
          HomePage(key: _homeKey),
          DebtsPage(key: _debtsKey),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: navBgColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                iconSize: 26,
                icon: Icon(LucideIcons.history, color: _currentIndex == 0 ? activeColor : inactiveColor),
                onPressed: () => setState(() => _currentIndex = 0),
              ),
              IconButton(
                iconSize: 26,
                icon: Icon(LucideIcons.layoutDashboard, color: _currentIndex == 1 ? activeColor : inactiveColor),
                onPressed: () => setState(() => _currentIndex = 1),
              ),
              IconButton(
                iconSize: 26,
                icon: Icon(LucideIcons.users, color: _currentIndex == 2 ? activeColor : inactiveColor),
                onPressed: () => setState(() => _currentIndex = 2),
              ),
              IconButton(
                iconSize: 26,
                icon: Icon(LucideIcons.settings, color: _currentIndex == 3 ? activeColor : inactiveColor),
                onPressed: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );

    final fabWidget = GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          var x = (_fabPosition?.dx ?? (screenSize.width - 80)) + details.delta.dx;
          var y = (_fabPosition?.dy ?? (screenSize.height - 160)) + details.delta.dy;
          
          // Keep it within screen bounds
          x = x.clamp(0.0, screenSize.width - 64);
          y = y.clamp(0.0, screenSize.height - 120);
          
          _fabPosition = Offset(x, y);
        });
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openAddTransactionSheet,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF43F5E), Color(0xFF8B5CF6)], // Rose to Purple
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: const Icon(LucideIcons.plus, color: Colors.white, size: 32),
          ),
        ),
      ),
    );

    return Stack(
      children: [
        scaffold,
        if (_fabPosition == null)
          Positioned(
            right: 16,
            bottom: 120, // Sit above the nav bar initially
            child: fabWidget,
          )
        else
          Positioned(
            left: _fabPosition!.dx,
            top: _fabPosition!.dy,
            child: fabWidget,
          ),
      ],
    );
  }
}
