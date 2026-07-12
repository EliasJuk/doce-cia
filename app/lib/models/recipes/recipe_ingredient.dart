class RecipeIngredient {
  const RecipeIngredient({
    this.id,
    required this.recipeId,
    required this.ingredientId,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;

  // Receita à qual o ingrediente pertence.
  final int recipeId;

  // Ingrediente cadastrado, como farinha, leite ou ovos.
  final int ingredientId;

  // Quantidade utilizada na receita.
  // Exemplo: 300 g, 100 ml ou 2 unidades.
  final double quantity;

  // Unidade utilizada na receita.
  // Valores esperados: g, kg, ml, L ou un.
  final String unit;

  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeIngredient copyWith({
    int? id,
    int? recipeId,
    int? ingredientId,
    double? quantity,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      ingredientId: ingredientId ?? this.ingredientId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap({
    bool includeId = true,
  }) {
    return {
      if (includeId) 'id': id,
      'recipe_id': recipeId,
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RecipeIngredient.fromMap(
    Map<String, Object?> map,
  ) {
    return RecipeIngredient(
      id: map['id'] as int?,
      recipeId: map['recipe_id'] as int,
      ingredientId: map['ingredient_id'] as int,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
    );
  }
}