import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'services/database_service.dart';
import 'models/category.dart';
import 'models/subcategory.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  List<CategoryModel> _categories = [];
  Map<int, List<SubCategoryModel>> _subcategoriesMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cats = await DatabaseService().getCategories();
    final Map<int, List<SubCategoryModel>> subMap = {};
    for (var cat in cats) {
      if (cat.id != null) {
        subMap[cat.id!] = await DatabaseService().getSubCategories(cat.id!);
      }
    }
    setState(() {
      _categories = cats;
      _subcategoriesMap = subMap;
    });
  }

  IconData _getIconData(String iconCode) {
    switch (iconCode) {
      case 'shoppingBag': return LucideIcons.shoppingBag;
      case 'car': return LucideIcons.car;
      case 'home': return LucideIcons.home;
      case 'monitor': return LucideIcons.monitor;
      case 'heart': return LucideIcons.heart;
      case 'coffee': return LucideIcons.coffee;
      case 'plane': return LucideIcons.plane;
      case 'music': return LucideIcons.music;
      case 'book': return LucideIcons.book;
      case 'briefcase': return LucideIcons.briefcase;
      case 'building': return LucideIcons.building;
      case 'bus': return LucideIcons.bus;
      case 'camera': return LucideIcons.camera;
      case 'dumbbell': return LucideIcons.dumbbell;
      case 'flame': return LucideIcons.flame;
      case 'gamepad2': return LucideIcons.gamepad2;
      case 'globe': return LucideIcons.globe;
      case 'graduationCap': return LucideIcons.graduationCap;
      case 'key': return LucideIcons.key;
      case 'leaf': return LucideIcons.leaf;
      case 'lightbulb': return LucideIcons.lightbulb;
      case 'palette': return LucideIcons.palette;
      case 'penTool': return LucideIcons.penTool;
      case 'pill': return LucideIcons.pill;
      case 'scissors': return LucideIcons.scissors;
      case 'shirt': return LucideIcons.shirt;
      case 'smartphone': return LucideIcons.smartphone;
      case 'truck': return LucideIcons.truck;
      case 'tv': return LucideIcons.tv;
      case 'umbrella': return LucideIcons.umbrella;
      case 'utensils': return LucideIcons.utensils;
      case 'zap': return LucideIcons.zap;
      default: return LucideIcons.circleDollarSign;
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    String selectedIcon = 'circleDollarSign';
    String selectedColor = '0xFF6366F1'; // Default Indigo
    
    final icons = [
      'shoppingBag', 'car', 'home', 'monitor', 'heart', 'coffee', 'plane', 'music', 'book', 'briefcase', 
      'circleDollarSign', 'building', 'bus', 'camera', 'dumbbell', 'flame', 'gamepad2', 'globe', 
      'graduationCap', 'key', 'leaf', 'lightbulb', 'palette', 'penTool', 'pill', 'scissors', 
      'shirt', 'smartphone', 'truck', 'tv', 'umbrella', 'utensils', 'zap'
    ];
    final colors = ['0xFFEF4444', '0xFFF59E0B', '0xFF10B981', '0xFF3B82F6', '0xFF6366F1', '0xFF8B5CF6', '0xFFEC4899'];

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Category'),
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Category Name'),
                    ),
                    const SizedBox(height: 24),
                    const Text('Select Icon', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: icons.map((icon) {
                        return ChoiceChip(
                          label: Icon(_getIconData(icon), color: selectedIcon == icon ? Colors.white : textColor, size: 20),
                          selected: selectedIcon == icon,
                          selectedColor: const Color(0xFF6366F1),
                          onSelected: (val) {
                            setDialogState(() => selectedIcon = icon);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: colors.map((color) {
                        final c = Color(int.parse(color));
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color ? textColor : Colors.transparent,
                                width: 2.5,
                              )
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      await DatabaseService().insertCategory(CategoryModel(
                        name: nameController.text,
                        iconCode: selectedIcon,
                        colorHex: selectedColor,
                      ));
                      if (context.mounted) Navigator.pop(context);
                      _loadData();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }
  
  void _showEditCategoryDialog(CategoryModel category) {
    final nameController = TextEditingController(text: category.name);
    String selectedIcon = category.iconCode;
    String selectedColor = category.colorHex;
    
    final icons = [
      'shoppingBag', 'car', 'home', 'monitor', 'heart', 'coffee', 'plane', 'music', 'book', 'briefcase', 
      'circleDollarSign', 'building', 'bus', 'camera', 'dumbbell', 'flame', 'gamepad2', 'globe', 
      'graduationCap', 'key', 'leaf', 'lightbulb', 'palette', 'penTool', 'pill', 'scissors', 
      'shirt', 'smartphone', 'truck', 'tv', 'umbrella', 'utensils', 'zap'
    ];
    final colors = ['0xFFEF4444', '0xFFF59E0B', '0xFF10B981', '0xFF3B82F6', '0xFF6366F1', '0xFF8B5CF6', '0xFFEC4899'];

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Category'),
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Category Name'),
                    ),
                    const SizedBox(height: 24),
                    const Text('Select Icon', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: icons.map((icon) {
                        return ChoiceChip(
                          label: Icon(_getIconData(icon), color: selectedIcon == icon ? Colors.white : textColor, size: 20),
                          selected: selectedIcon == icon,
                          selectedColor: const Color(0xFF6366F1),
                          onSelected: (val) {
                            setDialogState(() => selectedIcon = icon);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: colors.map((color) {
                        final c = Color(int.parse(color));
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color ? textColor : Colors.transparent,
                                width: 2.5,
                              )
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      await DatabaseService().updateCategory(CategoryModel(
                        id: category.id,
                        name: nameController.text,
                        iconCode: selectedIcon,
                        colorHex: selectedColor,
                      ));
                      if (context.mounted) Navigator.pop(context);
                      _loadData();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _showAddSubcategoryDialog(int categoryId) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          title: const Text('New Subcategory'),
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Subcategory Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await DatabaseService().insertSubCategory(SubCategoryModel(
                    categoryId: categoryId,
                    name: nameController.text,
                  ));
                  if (context.mounted) Navigator.pop(context);
                  _loadData();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }
  
  void _showEditSubcategoryDialog(SubCategoryModel sub) {
    final nameController = TextEditingController(text: sub.name);
    
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          title: const Text('Edit Subcategory'),
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Subcategory Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await DatabaseService().updateSubCategory(SubCategoryModel(
                    id: sub.id,
                    categoryId: sub.categoryId,
                    name: nameController.text,
                  ));
                  if (context.mounted) Navigator.pop(context);
                  _loadData();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final catColor = Color(int.parse(cat.colorHex));
          final subs = _subcategoriesMap[cat.id] ?? [];
          
          return Card(
            color: cardBg,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: catColor.withOpacity(0.2),
                child: Icon(_getIconData(cat.iconCode), color: catColor, size: 20),
              ),
              title: Row(
                children: [
                  Text(cat.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.edit2, size: 18, color: Color(0xFF6366F1)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showEditCategoryDialog(cat),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      await DatabaseService().deleteCategory(cat.id!);
                      _loadData();
                    },
                  ),
                ],
              ),
              children: [
                ...subs.map((sub) => ListTile(
                  title: Text(sub.name, style: TextStyle(color: textColor.withOpacity(0.8))),
                  contentPadding: const EdgeInsets.only(left: 72, right: 16),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.edit2, size: 16, color: Color(0xFF6366F1)),
                        onPressed: () => _showEditSubcategoryDialog(sub),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent),
                        onPressed: () async {
                          await DatabaseService().deleteSubCategory(sub.id!);
                          _loadData();
                        },
                      ),
                    ],
                  ),
                )).toList(),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 72, right: 16),
                  title: const Text('+ Add Subcategory', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
                  onTap: () => _showAddSubcategoryDialog(cat.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }
}
