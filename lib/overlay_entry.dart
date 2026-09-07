import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'widgets/add_transaction_sheet.dart';
import 'settings_state.dart';

@pragma("vm:entry-point")
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSettings();
  runApp(const OverlayApp());
}

class OverlayApp extends StatelessWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatHeadWidget(),
    );
  }
}

class ChatHeadWidget extends StatefulWidget {
  const ChatHeadWidget({super.key});

  @override
  State<ChatHeadWidget> createState() => _ChatHeadWidgetState();
}

class _ChatHeadWidgetState extends State<ChatHeadWidget> {
  bool _isExpanded = false;

  void _toggleExpanded() async {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      await FlutterOverlayWindow.resizeOverlay(
        WindowSize.matchParent,
        WindowSize.matchParent,
      );
      await FlutterOverlayWindow.updateFlag(OverlayFlag.focusPointer);
    } else {
      await FlutterOverlayWindow.resizeOverlay(200, 200);
      await FlutterOverlayWindow.updateFlag(OverlayFlag.defaultFlag);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF43F5E), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 32),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _toggleExpanded,
                child: Container(color: Colors.transparent),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48), // spacer for centering indicator
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.white),
                        onPressed: _toggleExpanded,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7, // take up most of screen
                    child: SingleChildScrollView(
                      child: AddTransactionSheet(
                        isDark: true,
                        shouldPop: false,
                        onTransactionAdded: () {
                          // Successfully added, tell main app to refresh, then collapse
                          FlutterOverlayWindow.shareData('refresh_transactions');
                          _toggleExpanded();
                        },
                      ),
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
