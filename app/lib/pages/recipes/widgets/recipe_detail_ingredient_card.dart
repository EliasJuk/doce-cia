import 'package:flutter/material.dart';

import '../../../models/ingredient/ingredient.dart';
import '../../../models/recipes/recipe_ingredient.dart';

class RecipeDetailIngredientCard extends StatelessWidget {
  const RecipeDetailIngredientCard({
    required this.ingredient,
    required this.recipeIngredient,
    required this.cost,
    super.key,
  });

  final Ingredient ingredient;
  final RecipeIngredient recipeIngredient;
  final double cost;

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value
        .toStringAsFixed(2)
        .replaceAll('.', ',');
  }

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.inventory_2_outlined,
            color: Theme.of(context)
                .colorScheme
                .onPrimaryContainer,
          ),
        ),
        title: Text(
          ingredient.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${_formatNumber(recipeIngredient.quantity)} '
          '${recipeIngredient.unit}',
        ),
        trailing: Text(
          _formatMoney(cost),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}