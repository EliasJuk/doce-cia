class Ingredient {
  const Ingredient({
    this.id,
    required this.name,
    required this.purchasePrice,
    required this.purchaseQuantity,
    required this.purchaseUnit,
    required this.baseQuantity,
    required this.baseUnit,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final double purchasePrice;
  final double purchaseQuantity;
  final String purchaseUnit;
  final double baseQuantity;
  final String baseUnit;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get baseUnitCost => baseQuantity <= 0 ? 0 : purchasePrice / baseQuantity;

  Map<String, Object?> toMap({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'name': name,
      'purchase_price': purchasePrice,
      'purchase_quantity': purchaseQuantity,
      'purchase_unit': purchaseUnit,
      'base_quantity': baseQuantity,
      'base_unit': baseUnit,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Ingredient.fromMap(Map<String, Object?> map) {
    return Ingredient(
      id: map['id'] as int?,
      name: map['name'] as String,
      purchasePrice: (map['purchase_price'] as num).toDouble(),
      purchaseQuantity: (map['purchase_quantity'] as num).toDouble(),
      purchaseUnit: map['purchase_unit'] as String,
      baseQuantity: (map['base_quantity'] as num).toDouble(),
      baseUnit: map['base_unit'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
