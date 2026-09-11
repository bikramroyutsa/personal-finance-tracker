import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/database_service.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/transaction_record.dart';
import '../settings_state.dart';

class AddTransactionSheet extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTransactionAdded;
  final bool shouldPop;

  const AddTransactionSheet({
    super.key, 
    required this.isDark, 
    required this.onTransactionAdded,
    this.shouldPop = true,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];
  
  CategoryModel? _selectedCategory;
  SubCategoryModel? _selectedSubCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    final cats = await DatabaseService().getCategories();
    if (cats.isNotEmpty && mounted) {
      setState(() {
        _categories = cats;
        _selectedCategory = cats.first;
      });
      _loadSubCategories(cats.first.id!);
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
  
  void _saveTransaction() async {
    if (_amountController.text.isEmpty || _selectedSubCategory == null) return;
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;
    
    final transaction = TransactionRecord(
      amount: amount,
      date: _selectedDate,
      subCategoryId: _selectedSubCategory!.id!,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    
    await DatabaseService().insertTransaction(transaction);
    widget.onTransactionAdded();
    if (mounted && widget.shouldPop) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF111827);
    final inputBg = widget.isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
    final currency = settingsNotifier.value.currency;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Transaction', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              if (widget.shouldPop)
                IconButton(icon: Icon(LucideIcons.x, color: textColor), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                prefixText: '$currency ',
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CategoryModel>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: inputBg,
                icon: Icon(LucideIcons.chevronDown, color: textColor),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat.name, style: TextStyle(color: textColor)));
                }).toList(),
                onChanged: (cat) {
                  if (cat != null) {
                    setState(() {
                      _selectedCategory = cat;
                      _loadSubCategories(cat.id!);
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // SubCategory
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SubCategoryModel>(
                value: _selectedSubCategory,
                isExpanded: true,
                dropdownColor: inputBg,
                icon: Icon(LucideIcons.chevronDown, color: textColor),
                items: _subCategories.map((sub) {
                  return DropdownMenuItem(value: sub, child: Text(sub.name, style: TextStyle(color: textColor)));
                }).toList(),
                onChanged: (sub) {
                  if (sub != null) setState(() => _selectedSubCategory = sub);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Date Picker
          Container(
            decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(LucideIcons.calendar, color: textColor.withOpacity(0.7)),
              title: Text(
                DateFormat('MMM d, yyyy').format(_selectedDate),
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(LucideIcons.chevronRight, color: textColor.withOpacity(0.5)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: widget.isDark 
                          ? const ColorScheme.dark(primary: Color(0xFF6366F1))
                          : const ColorScheme.light(primary: Color(0xFF6366F1)),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _noteController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Note (optional)',
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveTransaction,
              child: const Text('Save Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
