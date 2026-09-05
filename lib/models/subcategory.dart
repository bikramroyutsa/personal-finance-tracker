class SubCategoryModel {
  final int? id;
  final int categoryId;
  final String name;

  SubCategoryModel({
    this.id,
    required this.categoryId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'name': name,
    };
  }

  factory SubCategoryModel.fromMap(Map<String, dynamic> map) {
    return SubCategoryModel(
      id: map['id'],
      categoryId: map['category_id'],
      name: map['name'],
    );
  }
}
