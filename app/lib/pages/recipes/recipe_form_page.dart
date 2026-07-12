import 'package:flutter/material.dart';

import '../../models/categories/recipe_category.dart';
import '../../models/ingredient/ingredient.dart';
import '../../models/recipes/recipe.dart';
import '../../models/recipes/recipe_ingredient.dart';
import '../../repositories/ingredient_repository.dart';
import '../../repositories/recipes/recipe_ingredient_repository.dart';
import '../../repositories/recipes/recipe_repository.dart';
import 'widgets/recipe_ingredient_card.dart';
import 'widgets/recipe_ingredient_form.dart';

class RecipeFormPage extends StatefulWidget {
  const RecipeFormPage({
    required this.category,
    this.recipe,
    super.key,
  });

  final RecipeCategory category;
  final Recipe? recipe;

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  final _formKey = GlobalKey<FormState>();

  final RecipeRepository _recipeRepository = RecipeRepository();

  final RecipeIngredientRepository _recipeIngredientRepository =
      RecipeIngredientRepository();

  final IngredientRepository _ingredientRepository =
      IngredientRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _yieldQuantityController;
  late final TextEditingController _notesController;

  List<Ingredient> _availableIngredients = const [];
  List<RecipeIngredient> _recipeIngredients = const [];

  late String _selectedYieldUnit;

  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.recipe != null;

  static const List<String> _yieldUnits = [
    'unidades',
    'fatias',
    'porções',
    'gramas',
    'quilogramas',
  ];

  @override
  void initState() {
    super.initState();

    final recipe = widget.recipe;

    _nameController = TextEditingController(
      text: recipe?.name ?? '',
    );

    _yieldQuantityController = TextEditingController(
      text: recipe == null
          ? ''
          : _formatNumber(recipe.yieldQuantity),
    );

    _notesController = TextEditingController(
      text: recipe?.notes ?? '',
    );

    _selectedYieldUnit = recipe?.yieldUnit ?? 'unidades';

    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yieldQuantityController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ingredients = await _ingredientRepository.findAll();

      List<RecipeIngredient> recipeIngredients = const [];

      final recipeId = widget.recipe?.id;

      if (recipeId != null) {
        recipeIngredients =
            await _recipeIngredientRepository.findByRecipe(recipeId);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _availableIngredients = ingredients;
        _recipeIngredients = recipeIngredients;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double? _parseNumber(String value) {
    var normalized = value.trim();

    if (normalized.contains(',') && normalized.contains('.')) {
      normalized = normalized
          .replaceAll('.', '')
          .replaceAll(',', '.');
    } else {
      normalized = normalized.replaceAll(',', '.');
    }

    return double.tryParse(normalized);
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  String? _positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    final number = _parseNumber(value);

    if (number == null || number <= 0) {
      return 'Informe um valor maior que zero';
    }

    return null;
  }

  Ingredient? _findIngredient(int ingredientId) {
    for (final ingredient in _availableIngredients) {
      if (ingredient.id == ingredientId) {
        return ingredient;
      }
    }

    return null;
  }

  double _quantityInBaseUnit(
    RecipeIngredient recipeIngredient,
  ) {
    return switch (recipeIngredient.unit) {
      'kg' => recipeIngredient.quantity * 1000,
      'L' => recipeIngredient.quantity * 1000,
      _ => recipeIngredient.quantity,
    };
  }

  double _ingredientCost(
    RecipeIngredient recipeIngredient,
  ) {
    final ingredient = _findIngredient(
      recipeIngredient.ingredientId,
    );

    if (ingredient == null) {
      return 0;
    }

    return _quantityInBaseUnit(recipeIngredient) *
        ingredient.baseUnitCost;
  }

  double get _totalCost {
    return _recipeIngredients.fold(
      0,
      (total, item) => total + _ingredientCost(item),
    );
  }

  double get _costPerYield {
    final yieldQuantity = _parseNumber(
      _yieldQuantityController.text,
    );

    if (yieldQuantity == null || yieldQuantity <= 0) {
      return 0;
    }

    return _totalCost / yieldQuantity;
  }

  Future<void> _openIngredientForm([
    RecipeIngredient? current,
  ]) async {
    if (_availableIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre pelo menos um ingrediente antes de adicioná-lo à receita.',
          ),
        ),
      );

      return;
    }

    final result =
        await showDialog<RecipeIngredient>(
      context: context,
      builder: (_) {
        return RecipeIngredientForm(
          ingredients: _availableIngredients,
          current: current,
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      if (current == null) {
        _recipeIngredients = [
          ..._recipeIngredients,
          result,
        ];
      } else {
        final index = _recipeIngredients.indexOf(current);

        if (index < 0) {
          return;
        }

        final updated = [..._recipeIngredients];

        updated[index] = RecipeIngredient(
          id: current.id,
          recipeId: current.recipeId,
          ingredientId: result.ingredientId,
          quantity: result.quantity,
          unit: result.unit,
          createdAt: current.createdAt,
          updatedAt: DateTime.now(),
        );

        _recipeIngredients = updated;
      }
    });
  }

  void _removeIngredient(
    RecipeIngredient recipeIngredient,
  ) {
    setState(() {
      _recipeIngredients = _recipeIngredients
          .where((item) => item != recipeIngredient)
          .toList();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoryId = widget.category.id;

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A coleção não possui um ID válido.',
          ),
        ),
      );

      return;
    }

    if (_recipeIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Adicione pelo menos um ingrediente à receita.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final now = DateTime.now();

      final recipe = Recipe(
        id: widget.recipe?.id,
        categoryId: categoryId,
        name: _nameController.text.trim(),
        yieldQuantity: _parseNumber(
          _yieldQuantityController.text,
        )!,
        yieldUnit: _selectedYieldUnit,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.recipe?.createdAt ?? now,
        updatedAt: now,
      );

      late final int recipeId;

      if (_isEditing) {
        await _recipeRepository.update(recipe);

        recipeId = recipe.id!;
      } else {
        recipeId = await _recipeRepository.insert(recipe);
      }

      await _recipeIngredientRepository.replaceByRecipe(
        recipeId,
        _recipeIngredients,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar a receita: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Editar receita' : 'Nova receita',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Editar receita' : 'Nova receita',
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Não foi possível carregar os dados.',
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loadData,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar receita' : 'Nova receita',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '${widget.category.icon} ${widget.category.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome da receita',
                  hintText: 'Ex.: Cookie tradicional',
                  prefixIcon: Icon(
                    Icons.menu_book_outlined,
                  ),
                ),
                validator: _requiredText,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _yieldQuantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Rendimento',
                  hintText: 'Ex.: 20',
                  prefixIcon: Icon(
                    Icons.numbers_rounded,
                  ),
                ),
                validator: _positiveNumber,
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedYieldUnit,
                decoration: const InputDecoration(
                  labelText: 'Unidade do rendimento',
                  prefixIcon: Icon(
                    Icons.straighten_rounded,
                  ),
                ),
                items: _yieldUnits.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: _saving
                    ? null
                    : (unit) {
                        if (unit != null) {
                          setState(() {
                            _selectedYieldUnit = unit;
                          });
                        }
                      },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Observação',
                  hintText: 'Opcional',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(
                    Icons.notes_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ingredientes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _openIngredientForm(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_recipeIngredients.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 44,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Nenhum ingrediente adicionado',
                          style:
                              Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._recipeIngredients.map((recipeIngredient) {
                  final ingredient = _findIngredient(
                    recipeIngredient.ingredientId,
                  );

                  if (ingredient == null) {
                    return const SizedBox.shrink();
                  }

                  return RecipeIngredientCard(
                    recipeIngredient: recipeIngredient,
                    ingredient: ingredient,
                    onEdit: () {
                      _openIngredientForm(recipeIngredient);
                    },
                    onDelete: () {
                      _removeIngredient(recipeIngredient);
                    },
                  );
                }),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _CostRow(
                        label: 'Custo total',
                        value: _formatMoney(_totalCost),
                      ),
                      const SizedBox(height: 10),
                      _CostRow(
                        label: 'Custo por $_selectedYieldUnit',
                        value: _formatMoney(_costPerYield),
                        emphasized: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _saving
                      ? 'Salvando...'
                      : 'Salvar receita',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: style,
          ),
        ),
        Text(
          value,
          style: style?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}