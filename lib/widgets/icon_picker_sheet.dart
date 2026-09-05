import 'package:flutter/material.dart';
import '../utils/lucide_icons_map.dart';

class IconPickerSheet extends StatefulWidget {
  final String initialIcon;
  const IconPickerSheet({super.key, required this.initialIcon});

  @override
  State<IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<IconPickerSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    final filteredIcons = allLucideIcons.entries.where((entry) {
      return entry.key.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('Select Icon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          TextField(
            autofocus: true,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Search icons...',
              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              prefixIcon: Icon(Icons.search, color: textColor.withOpacity(0.5)),
              filled: true,
              fillColor: isDark ? Colors.black26 : Colors.grey[200],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredIcons.length,
              itemBuilder: (context, index) {
                final entry = filteredIcons[index];
                final isSelected = entry.key == widget.initialIcon;
                return GestureDetector(
                  onTap: () => Navigator.pop(context, entry.key),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6366F1) : (isDark ? Colors.black26 : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: const Color(0xFF6366F1), width: 2) : null,
                    ),
                    child: Icon(entry.value, color: isSelected ? Colors.white : textColor, size: 24),
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
