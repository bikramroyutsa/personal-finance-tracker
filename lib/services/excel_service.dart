import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'database_service.dart';

class ExcelService {
  static final ExcelService _instance = ExcelService._internal();
  factory ExcelService() => _instance;
  ExcelService._internal();

  Future<void> exportToExcel() async {
    final transactions = await DatabaseService().getAllTransactionsWithCategories();
    final debts = await DatabaseService().getDebts();

    // 1. Group data by Month-Year (e.g. "Sep 2026")
    // Map<String, List<Map<String, dynamic>>>
    final Map<String, List<Map<String, dynamic>>> monthlyTransactions = {};
    final Map<String, List<dynamic>> monthlyDebts = {};
    final Set<String> uniqueSubcats = {};

    for (var t in transactions) {
      final date = DateTime.fromMillisecondsSinceEpoch(t['date'] as int);
      final monthKey = DateFormat('MMM yy').format(date); // e.g. "Sep 26"
      monthlyTransactions.putIfAbsent(monthKey, () => []).add(t);
      uniqueSubcats.add(t['subcategory_name'] as String);
    }

    for (var d in debts) {
      final monthKey = DateFormat('MMM yy').format(d.date);
      monthlyDebts.putIfAbsent(monthKey, () => []).add(d);
    }

    // Combine month keys
    final allMonthKeys = {...monthlyTransactions.keys, ...monthlyDebts.keys}.toList();
    
    // Sort month keys chronologically
    allMonthKeys.sort((a, b) {
      final da = DateFormat('MMM yy').parse(a);
      final db = DateFormat('MMM yy').parse(b);
      return da.compareTo(db);
    });

    final subcatList = uniqueSubcats.toList()..sort();

    // Columns: Date, [Subcategories...], Total, Notes, Lent, Borrowed
    final headerRow = [
      'Date',
      ...subcatList,
      'Total',
      'Notes',
      'Lent',
      'Borrowed'
    ];

    var excel = Excel.createExcel();
    
    // Excel creates a default sheet named "Sheet1", let's rename or remove it later.
    bool firstSheet = true;

    for (var monthKey in allMonthKeys) {
      // Create or get sheet
      String sheetName = monthKey;
      Sheet sheetObject;
      if (firstSheet) {
        excel.rename('Sheet1', sheetName);
        sheetObject = excel[sheetName];
        firstSheet = false;
      } else {
        sheetObject = excel[sheetName];
      }

      // Write Header
      for (int i = 0; i < headerRow.length; i++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headerRow[i]);
      }

      // Group by day
      final txForMonth = monthlyTransactions[monthKey] ?? [];
      final dbForMonth = monthlyDebts[monthKey] ?? [];

      // Determine the month and year for this tab
      final parsedDate = DateFormat('MMM yy').parse(monthKey);
      final daysInMonth = DateTime(parsedDate.year, parsedDate.month + 1, 0).day;

      for (int day = 1; day <= daysInMonth; day++) {
        // Find transactions for this day
        final dailyTx = txForMonth.where((t) {
          final d = DateTime.fromMillisecondsSinceEpoch(t['date'] as int);
          return d.day == day;
        }).toList();

        final dailyDb = dbForMonth.where((d) => d.date.day == day).toList();

        if (dailyTx.isEmpty && dailyDb.isEmpty) {
          // You can choose to skip empty days or print an empty row with just the date.
          // The user's screenshot shows empty rows for empty days.
          var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: day));
          cell.value = IntCellValue(day);
          continue;
        }

        // Aggregate transactions by subcategory
        final Map<String, double> subcatTotals = {};
        double dayTotal = 0;
        List<String> notes = [];

        for (var t in dailyTx) {
          final sub = t['subcategory_name'] as String;
          final amt = t['amount'] as double;
          subcatTotals[sub] = (subcatTotals[sub] ?? 0) + amt;
          dayTotal += amt;
          
          if (t['note'] != null && t['note'].toString().trim().isNotEmpty) {
            notes.add(t['note'].toString().trim());
          }
        }

        double lentTotal = 0;
        double borrowedTotal = 0;
        for (var d in dailyDb) {
          if (d.type == 'Lent') lentTotal += d.amount;
          if (d.type == 'Borrowed') borrowedTotal += d.amount;
          
          String debtNote = d.personName;
          if (d.note != null && d.note!.isNotEmpty) {
            debtNote += ': ${d.note}';
          }
          notes.add(debtNote);
        }

        // Write row
        // 0: Date
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: day)).value = IntCellValue(day);

        // 1 to N: Subcategories
        for (int i = 0; i < subcatList.length; i++) {
          final sub = subcatList[i];
          if (subcatTotals.containsKey(sub)) {
            sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1 + i, rowIndex: day)).value = DoubleCellValue(subcatTotals[sub]!);
          }
        }

        int colOffset = 1 + subcatList.length;
        
        // Total
        if (dayTotal > 0) {
          sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: colOffset, rowIndex: day)).value = DoubleCellValue(dayTotal);
        }
        
        // Notes
        if (notes.isNotEmpty) {
          sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: colOffset + 1, rowIndex: day)).value = TextCellValue(notes.join(', '));
        }
        
        // Lent
        if (lentTotal > 0) {
          sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: colOffset + 2, rowIndex: day)).value = DoubleCellValue(lentTotal);
        }
        
        // Borrowed
        if (borrowedTotal > 0) {
          sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: colOffset + 3, rowIndex: day)).value = DoubleCellValue(borrowedTotal);
        }
      }
    }

    final fileBytes = excel.encode();
    if (fileBytes != null) {
      await FilePicker.saveFile(
        dialogTitle: 'Save Excel File',
        fileName: 'finance_tracker_export.xlsx',
        bytes: Uint8List.fromList(fileBytes),
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
    }
  }
}
