class Recipe {
  const Recipe({
    this.id,
    required this.categoryId,
    required this.name,
    required this.yieldQuantity,
    required this.yieldUnit,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;

  // Coleção à qual a receita pertence.
  // Exemplo: Cookies, Tortas ou Brownies.
  final int categoryId;

  final String name;

  // Quantidade produzida pela receita.
  // Exemplo: 20 cookies ou 10 fatias.
  final double yieldQuantity;

  // Unidade do rendimento.
  // Exemplo: unidades, fatias ou porções.
  final String yieldUnit;

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe copyWith({
    int? id,
    int? categoryId,
    String? name,
    double? yieldQuantity,
    String? yieldUnit,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      yieldQuantity: yieldQuantity ?? this.yieldQuantity,
      yieldUnit: yieldUnit ?? this.yieldUnit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap({
    bool includeId = true,
  }) {
    return {
      if (includeId) 'id': id,
      'category_id': categoryId,
      'name': name,
      'yield_quantity': yieldQuantity,
      'yield_unit': yieldUnit,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Recipe.fromMap(
    Map<String, Object?> map,
  ) {
    return Recipe(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      yieldQuantity:
          (map['yield_quantity'] as num).toDouble(),
      yieldUnit: map['yield_unit'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
    );
  }
}