class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? parentId;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.parentId,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      parentId: json['parent_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
