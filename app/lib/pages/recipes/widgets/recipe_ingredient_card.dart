import 'package:flutter/material.dart';

import '../../../models/ingredient/ingredient.dart';
import '../../../models/recipes/recipe_ingredient.dart';

class RecipeIngredientCard extends StatelessWidget {
  const RecipeIngredientCard({
    required this.recipeIngredient,
    required this.ingredient,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final RecipeIngredient recipeIngredient;
  final Ingredient ingredient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  double get _cost {
    final quantityInBaseUnit = switch (recipeIngredient.unit) {
      'kg' => recipeIngredient.quantity * 1000,
      'L' => recipeIngredient.quantity * 1000,
      _ => recipeIngredient.quantity,
    };

    return quantityInBaseUnit * ingredient.baseUnitCost;
  }

  String _money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.inventory_2_outlined),
        title: Text(ingredient.name),
        subtitle: Text(
          '${recipeIngredient.quantity} '
          '${recipeIngredient.unit} • ${_money(_cost)}',
        ),
        trailing: PopupMenuButton<String>(
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
      ),
    );
  }
}