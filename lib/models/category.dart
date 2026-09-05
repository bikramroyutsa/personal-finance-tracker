class CategoryModel {
  final int? id;
  final String name;
  final String iconCode;
  final String colorHex;

  CategoryModel({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorHex,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon_code': iconCode,
      'color_hex': colorHex,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      iconCode: map['icon_code'],
      colorHex: map['color_hex'],
    );
  }
}
