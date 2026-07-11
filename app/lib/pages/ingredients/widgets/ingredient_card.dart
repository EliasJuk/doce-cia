import 'package:flutter/material.dart';

import '../../../models/ingredient/ingredient.dart';

class IngredientCard extends StatelessWidget {
  const IngredientCard({
    required this.ingredient,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Ingredient ingredient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _money(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

  String _quantity(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _unitCost() {
    final value = ingredient.baseUnitCost;
    final decimals = value < 0.01 ? 4 : 2;

    return 'R\$ ${value.toStringAsFixed(decimals).replaceAll('.', ',')}'
        ' por ${ingredient.baseUnit}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.inventory_2_rounded),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_quantity(ingredient.purchaseQuantity)} '
                      '${ingredient.purchaseUnit} por '
                      '${_money(ingredient.purchasePrice)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _unitCost(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Excluir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
