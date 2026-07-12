class Sale {
  const Sale({
    this.id,
    required this.recipeId,
    required this.recipeName,
    required this.quantity,
    required this.unitPrice,
    required this.unitCost,
    required this.saleDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int? recipeId;

  // Guardamos o nome para preservar o histórico caso a receita
  // seja renomeada ou removida posteriormente.
  final String recipeName;

  final double quantity;
  final double unitPrice;

  // Custo unitário registrado no momento da venda.
  final double unitCost;

  final DateTime saleDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get totalValue {
    return quantity * unitPrice;
  }

  double get totalCost {
    return quantity * unitCost;
  }

  double get grossProfit {
    return totalValue - totalCost;
  }

  Map<String, Object?> toMap({
    bool includeId = true,
  }) {
    return {
      if (includeId) 'id': id,
      'recipe_id': recipeId,
      'recipe_name': recipeName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'unit_cost': unitCost,
      'sale_date': saleDate.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Sale.fromMap(
    Map<String, Object?> map,
  ) {
    return Sale(
      id: map['id'] as int?,
      recipeId: map['recipe_id'] as int?,
      recipeName: map['recipe_name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      unitCost: (map['unit_cost'] as num).toDouble(),
      saleDate: DateTime.parse(
        map['sale_date'] as String,
      ),
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