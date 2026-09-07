import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/database_service.dart';
import '../models/debt_record.dart';
import '../settings_state.dart';

class AddDebtSheet extends StatefulWidget {
  final VoidCallback onDebtAdded;
  final bool isDark;

  const AddDebtSheet({super.key, required this.onDebtAdded, required this.isDark});

  @override
  State<AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<AddDebtSheet> {
  final _amountController = TextEditingController();
  final _personNameController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedType = 'Lent'; // Lent or Borrowed
  final DateTime _selectedDate = DateTime.now();
  
  Future<void> _saveDebt() async {
    if (_amountController.text.isEmpty || _personNameController.text.isEmpty) return;
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    
    final debt = DebtRecord(
      type: _selectedType,
      amount: amount,
      personName: _personNameController.text.trim(),
      date: _selectedDate,
      status: 'Pending',
      note: _noteController.text.isEmpty ? null : _noteController.text.trim(),
    );
    
    await DatabaseService().insertDebt(debt);
    widget.onDebtAdded();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF111827);
    final inputBg = widget.isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
    final currency = settingsNotifier.value.currency;
    final primaryColor = _selectedType == 'Lent' ? Colors.green : Colors.red;
    
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
              Text('Add Debt/Loan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              IconButton(icon: Icon(LucideIcons.x, color: textColor), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Type Toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = 'Lent'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedType == 'Lent' ? Colors.green.withOpacity(0.2) : inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedType == 'Lent' ? Colors.green : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text('I Lent', style: TextStyle(
                      color: _selectedType == 'Lent' ? Colors.green : textColor.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = 'Borrowed'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedType == 'Borrowed' ? Colors.red.withOpacity(0.2) : inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedType == 'Borrowed' ? Colors.red : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text('I Borrowed', style: TextStyle(
                      color: _selectedType == 'Borrowed' ? Colors.red : textColor.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                ),
              ),
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                prefixText: '$currency ',
                prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Person Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _personNameController,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Person Name',
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                icon: Icon(LucideIcons.user, color: textColor.withOpacity(0.5)),
              ),
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
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveDebt,
              child: const Text('Save Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
