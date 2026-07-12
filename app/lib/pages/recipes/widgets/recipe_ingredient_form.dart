import 'package:flutter/material.dart';

import '../../../models/ingredient/ingredient.dart';
import '../../../models/recipes/recipe_ingredient.dart';

class RecipeIngredientForm extends StatefulWidget {
  const RecipeIngredientForm({
    required this.ingredients,
    this.current,
    super.key,
  });

  final List<Ingredient> ingredients;
  final RecipeIngredient? current;

  @override
  State<RecipeIngredientForm> createState() =>
      _RecipeIngredientFormState();
}

class _RecipeIngredientFormState
    extends State<RecipeIngredientForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  Ingredient? _selectedIngredient;
  String _selectedUnit = 'g';

  @override
  void initState() {
    super.initState();

    final current = widget.current;

    if (current != null) {
      _selectedIngredient = widget.ingredients.firstWhere(
        (ingredient) => ingredient.id == current.ingredientId,
      );

      _selectedUnit = current.unit;
      _quantityController.text =
          current.quantity.toString().replaceAll('.', ',');
    } else if (widget.ingredients.isNotEmpty) {
      _selectedIngredient = widget.ingredients.first;
      _selectedUnit = _selectedIngredient!.baseUnit;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  double? _parseNumber(String value) {
    return double.tryParse(
      value.trim().replaceAll(',', '.'),
    );
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;

    final ingredient = _selectedIngredient;

    if (ingredient == null || ingredient.id == null) {
      return;
    }

    final now = DateTime.now();

    Navigator.of(context).pop(
      RecipeIngredient(
        id: widget.current?.id,
        recipeId: widget.current?.recipeId ?? 0,
        ingredientId: ingredient.id!,
        quantity: _parseNumber(_quantityController.text)!,
        unit: _selectedUnit,
        createdAt: widget.current?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.current == null
            ? 'Adicionar ingrediente'
            : 'Editar ingrediente',
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Ingredient>(
                initialValue: _selectedIngredient,
                decoration: const InputDecoration(
                  labelText: 'Ingrediente',
                ),
                items: widget.ingredients.map((ingredient) {
                  return DropdownMenuItem(
                    value: ingredient,
                    child: Text(ingredient.name),
                  );
                }).toList(),
                onChanged: (ingredient) {
                  if (ingredient == null) return;

                  setState(() {
                    _selectedIngredient = ingredient;
                    _selectedUnit = ingredient.baseUnit;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantidade usada',
                ),
                validator: (value) {
                  final number = value == null
                      ? null
                      : _parseNumber(value);

                  if (number == null || number <= 0) {
                    return 'Informe uma quantidade válida';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unidade',
                ),
                items: const [
                  DropdownMenuItem(value: 'g', child: Text('g')),
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'ml', child: Text('ml')),
                  DropdownMenuItem(value: 'L', child: Text('L')),
                  DropdownMenuItem(value: 'un', child: Text('un')),
                ],
                onChanged: (unit) {
                  if (unit != null) {
                    setState(() => _selectedUnit = unit);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirm,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}