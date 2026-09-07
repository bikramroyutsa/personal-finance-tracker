import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'services/database_service.dart';
import 'settings_state.dart';
import 'models/debt_record.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => DebtsPageState();
}

class DebtsPageState extends State<DebtsPage> {
  List<DebtRecord> _debts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await DatabaseService().getDebts();
    setState(() {
      _debts = data;
      _isLoading = false;
    });
  }

  Future<void> _toggleStatus(DebtRecord debt) async {
    final newStatus = debt.status == 'Pending' ? 'Settled' : 'Pending';
    final updated = DebtRecord(
      id: debt.id,
      type: debt.type,
      amount: debt.amount,
      personName: debt.personName,
      date: debt.date,
      status: newStatus,
      note: debt.note,
    );
    await DatabaseService().updateDebt(updated);
    await loadData();
  }

  Future<void> _deleteDebt(DebtRecord debt) async {
    await DatabaseService().deleteDebt(debt.id!);
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Debts Tracker')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate Totals
    double totalLent = 0;
    double totalBorrowed = 0;
    for (var d in _debts) {
      if (d.status == 'Pending') {
        if (d.type == 'Lent') totalLent += d.amount;
        if (d.type == 'Borrowed') totalBorrowed += d.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Debts & Loans', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
      ),
      body: Column(
        children: [
          // Summary Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('You are owed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('${settingsNotifier.value.currency}${totalLent.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('You owe', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('${settingsNotifier.value.currency}${totalBorrowed.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _debts.isEmpty
                ? Center(child: Text('No debts tracked.', style: TextStyle(color: textColor.withOpacity(0.5))))
                : ListView.builder(
                    padding: const EdgeInsets.all(16).copyWith(bottom: 120),
                    itemCount: _debts.length,
                    itemBuilder: (context, index) {
                      final debt = _debts[index];
                      final isLent = debt.type == 'Lent';
                      final isSettled = debt.status == 'Settled';
                      
                      final primaryColor = isLent ? Colors.green : Colors.red;
                      final displayColor = isSettled ? Colors.grey : primaryColor;

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
                              color: displayColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(isLent ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft, color: displayColor, size: 20),
                          ),
                          title: Text(
                            debt.personName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              decoration: isSettled ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${debt.type} • ${DateFormat("MMM d, yyyy").format(debt.date)}',
                                style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                              ),
                              if (debt.note != null && debt.note!.isNotEmpty)
                                Text(debt.note!, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${settingsNotifier.value.currency}${debt.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: displayColor,
                                  fontSize: 16,
                                  decoration: isSettled ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(LucideIcons.moreVertical, color: textColor.withOpacity(0.5)),
                                onSelected: (value) {
                                  if (value == 'toggle') {
                                    _toggleStatus(debt);
                                  } else if (value == 'delete') {
                                    _deleteDebt(debt);
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'toggle',
                                    child: Text(isSettled ? 'Mark as Pending' : 'Mark as Settled'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
