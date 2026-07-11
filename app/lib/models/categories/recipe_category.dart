class RecipeCategory {
  const RecipeCategory({
    this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeCategory copyWith({
    int? id,
    String? name,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap({
    bool includeId = true,
  }) {
    return {
      if (includeId) 'id': id,
      'name': name,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RecipeCategory.fromMap(
    Map<String, Object?> map,
  ) {
    return RecipeCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String? ?? '📁',
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
    );
  }
}