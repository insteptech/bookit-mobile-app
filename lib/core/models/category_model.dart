class CategoryModel {
  final String id;
  final String? parentId;
  final String slug;
  final String name;
  final String? description;
  final int level;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.parentId,
    required this.slug,
    required this.name,
    this.description,
    required this.level,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      parentId: json['parent_id'],
      slug: json['slug'],
      name: json['name'],
      description: json['description'],
      level: json['level'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'slug': slug,
      'name': name,
      'description': description,
      'level': level,
      'is_active': isActive,
      'createdAt': createdAt != null ? createdAt?.toIso8601String() : "",
      'updatedAt': updatedAt != null ? updatedAt?.toIso8601String() : "",
    };
  }
}
