enum IngredientUnit {
  gram(label: 'Grama', symbol: 'g', baseUnit: 'g', multiplier: 1),
  kilogram(label: 'Quilograma', symbol: 'kg', baseUnit: 'g', multiplier: 1000),
  milliliter(label: 'Mililitro', symbol: 'ml', baseUnit: 'ml', multiplier: 1),
  liter(label: 'Litro', symbol: 'L', baseUnit: 'ml', multiplier: 1000),
  unit(label: 'Unidade', symbol: 'un', baseUnit: 'un', multiplier: 1);

  const IngredientUnit({
    required this.label,
    required this.symbol,
    required this.baseUnit,
    required this.multiplier,
  });

  final String label;
  final String symbol;
  final String baseUnit;
  final double multiplier;

  double toBaseQuantity(double quantity) => quantity * multiplier;

  static IngredientUnit fromSymbol(String symbol) {
    return IngredientUnit.values.firstWhere(
      (unit) => unit.symbol == symbol,
      orElse: () => IngredientUnit.unit,
    );
  }
}
