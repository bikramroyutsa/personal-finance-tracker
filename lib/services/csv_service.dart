import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction_record.dart';
import '../models/debt_record.dart';
import 'database_service.dart';

class CsvService {
  static final CsvService _instance = CsvService._internal();
  factory CsvService() => _instance;
  CsvService._internal();

  final DatabaseService _db = DatabaseService();

  Future<void> exportToCsv() async {
    final transactions = await _db.getAllTransactionsWithCategories();
    final debts = await _db.getDebts();
    
    List<List<dynamic>> rows = [];
    // Header
    rows.add(['Date', 'Type', 'Category', 'Subcategory', 'Amount', 'Note', 'Status']);

    // Transactions
    for (var t in transactions) {
      final date = DateTime.fromMillisecondsSinceEpoch(t['date']);
      final dateStr = "\${date.year}-\${date.month.toString().padLeft(2, '0')}-\${date.day.toString().padLeft(2, '0')}";
      rows.add([
        dateStr,
        'Expense',
        t['category_name'],
        t['subcategory_name'],
        t['amount'],
        t['note'] ?? '',
        ''
      ]);
    }

    // Debts
    for (var d in debts) {
      final dateStr = "\${d.date.year}-\${d.date.month.toString().padLeft(2, '0')}-\${d.date.day.toString().padLeft(2, '0')}";
      rows.add([
        dateStr,
        d.type,
        'Debt', // Using a generic category for debts
        d.personName, // Using subcategory field for personName
        d.amount,
        d.note ?? '',
        d.status
      ]);
    }

    String csvData = csv.encode(rows);

    final bytes = Uint8List.fromList(utf8.encode(csvData));
    Uri? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Save Finance CSV',
      fileName: 'finances_export.csv',
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
  }

  Future<String> importFromCsv() async {
    try {
      PlatformFile? result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.path != null) {
        final file = File(result.path!);
        final input = await file.readAsString();
        final List<List<dynamic>> rows = csv.decode(input);

        if (rows.isEmpty) return 'File is empty';

        // Assuming first row is header: Date, Type, Category, Subcategory, Amount, Note
        final header = rows[0].map((e) => e.toString().toLowerCase().trim()).toList();
        
        int dateIdx = header.indexOf('date');
        int typeIdx = header.indexOf('type');
        int catIdx = header.indexOf('category');
        int subcatIdx = header.indexOf('subcategory');
        int amountIdx = header.indexOf('amount');
        int noteIdx = header.indexOf('note');
        int statusIdx = header.indexOf('status');

        if (dateIdx == -1 || typeIdx == -1 || amountIdx == -1) {
          return 'Invalid CSV format. Missing required columns (Date, Type, Amount).';
        }

        int importedCount = 0;

        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.length <= amountIdx) continue;

          final dateStr = row[dateIdx].toString().trim();
          final type = row[typeIdx].toString().trim();
          final amountStr = row[amountIdx].toString().trim();
          
          if (dateStr.isEmpty || amountStr.isEmpty) continue;

          DateTime? parsedDate;
          try {
            parsedDate = DateTime.parse(dateStr);
          } catch (e) {
            continue; // Skip invalid dates
          }

          double amount = double.tryParse(amountStr) ?? 0.0;
          if (amount <= 0) continue;

          String note = noteIdx != -1 && row.length > noteIdx ? row[noteIdx].toString().trim() : '';
          
          if (type.toLowerCase() == 'expense') {
            String categoryName = catIdx != -1 && row.length > catIdx ? row[catIdx].toString().trim() : 'Uncategorized';
            String subcategoryName = subcatIdx != -1 && row.length > subcatIdx ? row[subcatIdx].toString().trim() : 'General';
            
            if (categoryName.isEmpty) categoryName = 'Uncategorized';
            if (subcategoryName.isEmpty) subcategoryName = 'General';

            final category = await _db.getOrCreateCategory(categoryName);
            final subcategory = await _db.getOrCreateSubCategory(subcategoryName, category.id!);

            await _db.insertTransaction(TransactionRecord(
              amount: amount,
              date: parsedDate,
              subCategoryId: subcategory.id!,
              note: note.isNotEmpty ? note : null,
            ));
            importedCount++;
          } else if (type.toLowerCase() == 'lent' || type.toLowerCase() == 'borrowed') {
            // For debts, subcategory column acts as the personName. 
            // In case personName was extracted differently (like if they use older CSV), 
            // we try to use subcategory or category as fallback.
            String personName = subcatIdx != -1 && row.length > subcatIdx ? row[subcatIdx].toString().trim() : 'Unknown';
            if (personName.isEmpty) personName = 'Unknown';

            String status = statusIdx != -1 && row.length > statusIdx ? row[statusIdx].toString().trim() : 'Pending';
            if (status.isEmpty) status = 'Pending';

            // Also try to extract from note if personName is 'Unknown' and we know we imported a fuzzy old CSV
            if (personName == 'Unknown' || personName == 'Lent' || personName == 'Borrowed') {
              // Try to find a name in the note, this is a very basic heuristic based on user feedback
              final noteLower = note.toLowerCase();
              if (noteLower.startsWith('paid ')) {
                 personName = note.substring(5).split(' ').first;
                 // Keep it capitalized
                 personName = personName[0].toUpperCase() + personName.substring(1);
              } else if (noteLower.contains('paid for ')) {
                 personName = noteLower.split('paid for')[0].trim();
                 if (personName.isNotEmpty) {
                    personName = personName[0].toUpperCase() + personName.substring(1);
                 } else {
                    personName = 'Unknown';
                 }
              }
            }

            // Ensure personName is Title Case
            if (personName.isNotEmpty && personName != 'Unknown') {
               personName = personName[0].toUpperCase() + personName.substring(1);
            }

            await _db.insertDebt(DebtRecord(
              type: type.substring(0, 1).toUpperCase() + type.substring(1).toLowerCase(), // "Lent" or "Borrowed"
              amount: amount,
              personName: personName,
              date: parsedDate,
              status: status,
              note: note.isNotEmpty ? note : null,
            ));
            importedCount++;
          }
        }
        return 'Successfully imported $importedCount records.';
      } else {
        return 'Import cancelled.';
      }
    } catch (e) {
      return 'Error importing CSV: $e';
    }
  }
}
