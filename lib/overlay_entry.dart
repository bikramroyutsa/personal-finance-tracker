import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'models/category.dart';
import 'models/subcategory.dart';
import 'models/transaction_record.dart';
import 'services/database_service.dart';
import 'settings_state.dart';

class ChatHeadWidget extends StatefulWidget {
  const ChatHeadWidget({super.key});

  @override
  State<ChatHeadWidget> createState() => _ChatHeadWidgetState();
}

class _ChatHeadWidgetState extends State<ChatHeadWidget> {
  bool _isExpanded = false;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];
  CategoryModel? _selectedCategory;
  SubCategoryModel? _selectedSubCategory;
  String _currency = '\$';
  bool _saved = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await initSettings();
      final cats = await DatabaseService().getCategories();
      if (cats.isNotEmpty && mounted) {
        final subs = await DatabaseService().getSubCategories(cats.first.id!);
        setState(() {
          _categories = cats;
          _selectedCategory = cats.first;
          _subCategories = subs;
          _selectedSubCategory = subs.isNotEmpty ? subs.first : null;
          _currency = settingsNotifier.value.currency;
          _errorMsg = null;
        });
      } else if (mounted) {
        setState(() => _errorMsg = 'No categories found');
      }
    } catch (e) {
      if (mounted) setState(() => _errorMsg = e.toString());
    }
  }

  Future<void> _loadSubCategories(int categoryId) async {
    final subs = await DatabaseService().getSubCategories(categoryId);
    if (mounted) {
      setState(() {
        _subCategories = subs;
        _selectedSubCategory = subs.isNotEmpty ? subs.first : null;
      });
    }
  }

  void _expand() async {
    // 1. Expand native window to full screen (WindowSize.matchParent for width, 1200 dp for height)
    await FlutterOverlayWindow.resizeOverlay(
      WindowSize.matchParent,
      1200,
      false,
    );
    // 2. Load latest categories
    await _loadData();
    // 3. Render expanded UI
    if (mounted) {
      setState(() => _isExpanded = true);
    }
  }

  void _collapse() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (mounted) {
      setState(() {
        _isExpanded = false;
        _saved = false;
        _amountController.clear();
        _noteController.clear();
      });
    }
    try {
      await FlutterOverlayWindow.resizeOverlay(80, 80, true);
    } catch (_) {}
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty || _selectedSubCategory == null) return;
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final transaction = TransactionRecord(
      amount: amount,
      date: DateTime.now(),
      subCategoryId: _selectedSubCategory!.id!,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    try {
      await DatabaseService().insertTransaction(transaction);
    } catch (e) {
      if (mounted) setState(() => _errorMsg = 'Failed to save: $e');
      return;
    }
    
    // Fire-and-forget notification to main app (do NOT await because it hangs indefinitely when main app is in background/closed)
    FlutterOverlayWindow.shareData('refresh_transactions').catchError((_) {});

    if (mounted) {
      setState(() => _saved = true);
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _collapse();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _expand,
          child: Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1), // Primary Theme Indigo
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
            ),
          ),
        ),
      );
    }

    // Expanded form
    const bgColor = Color(0xFF1F2937);
    const textColor = Colors.white;
    const inputBg = Color(0xFF374151);

    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Column(
          children: [
            // Tap to dismiss area
            Expanded(
              child: GestureDetector(
                onTap: _collapse,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Form
            Container(
              decoration: const BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: _saved
                    ? const SizedBox(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.checkCircle, color: Colors.green, size: 48),
                              SizedBox(height: 12),
                              Text('Saved!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Quick Add', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                              IconButton(
                                icon: const Icon(LucideIcons.x, color: textColor),
                                onPressed: _collapse,
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),

                        if (_errorMsg != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent)),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Amount
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0.00',
                              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                              prefixText: '$_currency ',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CategoryModel>(
                              value: _selectedCategory,
                              isExpanded: true,
                              dropdownColor: inputBg,
                              icon: const Icon(LucideIcons.chevronDown, color: textColor),
                              items: _categories.map((cat) {
                                return DropdownMenuItem(value: cat, child: Text(cat.name, style: const TextStyle(color: textColor)));
                              }).toList(),
                              onChanged: (cat) {
                                if (cat != null) {
                                  setState(() => _selectedCategory = cat);
                                  _loadSubCategories(cat.id!);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // SubCategory
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<SubCategoryModel>(
                              value: _selectedSubCategory,
                              isExpanded: true,
                              dropdownColor: inputBg,
                              icon: const Icon(LucideIcons.chevronDown, color: textColor),
                              items: _subCategories.map((sub) {
                                return DropdownMenuItem(value: sub, child: Text(sub.name, style: const TextStyle(color: textColor)));
                              }).toList(),
                              onChanged: (sub) {
                                if (sub != null) setState(() => _selectedSubCategory = sub);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Note
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
                          child: TextField(
                            controller: _noteController,
                            style: const TextStyle(color: textColor),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Note (optional)',
                              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Save
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _saveTransaction,
                            child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
