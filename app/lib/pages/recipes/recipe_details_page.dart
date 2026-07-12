import 'package:flutter/material.dart';

import '../../models/categories/recipe_category.dart';
import '../../models/ingredient/ingredient.dart';
import '../../models/recipes/recipe.dart';
import '../../models/recipes/recipe_ingredient.dart';
import '../../repositories/ingredient_repository.dart';
import '../../repositories/recipes/recipe_ingredient_repository.dart';
import '../../repositories/recipes/recipe_repository.dart';
import 'recipe_form_page.dart';
import 'widgets/recipe_detail_ingredient_card.dart';

class RecipeDetailsPage extends StatefulWidget {
  const RecipeDetailsPage({
    required this.category,
    required this.recipe,
    super.key,
  });

  final RecipeCategory category;
  final Recipe recipe;

  @override
  State<RecipeDetailsPage> createState() =>
      _RecipeDetailsPageState();
}

class _RecipeDetailsPageState
    extends State<RecipeDetailsPage> {
  final RecipeRepository _recipeRepository =
      RecipeRepository();

  final IngredientRepository _ingredientRepository =
      IngredientRepository();

  final RecipeIngredientRepository
      _recipeIngredientRepository =
      RecipeIngredientRepository();

  late Recipe _recipe;

  List<Ingredient> _ingredients = const [];
  List<RecipeIngredient> _recipeIngredients = const [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _recipe = widget.recipe;

    _loadData();
  }

  Future<void> _loadData() async {
    final recipeId = _recipe.id;

    if (recipeId == null) {
      setState(() {
        _loading = false;
        _error = 'A receita não possui um ID válido.';
      });

      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final recipe = await _recipeRepository.findById(
        recipeId,
      );

      final ingredients =
          await _ingredientRepository.findAll();

      final recipeIngredients =
          await _recipeIngredientRepository.findByRecipe(
        recipeId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (recipe != null) {
          _recipe = recipe;
        }

        _ingredients = ingredients;
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

  Ingredient? _findIngredient(int ingredientId) {
    for (final ingredient in _ingredients) {
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
    return _recipeIngredients.fold<double>(
      0,
      (total, item) {
        return total + _ingredientCost(item);
      },
    );
  }

  double get _costPerYield {
    if (_recipe.yieldQuantity <= 0) {
      return 0;
    }

    return _totalCost / _recipe.yieldQuantity;
  }

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

  Future<void> _editRecipe() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecipeFormPage(
          category: widget.category,
          recipe: _recipe,
        ),
      ),
    );

    if (changed == true) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da receita'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _editRecipe,
            tooltip: 'Editar receita',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Não foi possível carregar a receita.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadData,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          40,
        ),
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildSummary(context),
          if (_recipe.notes != null &&
              _recipe.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildNotes(context),
          ],
          const SizedBox(height: 28),
          Text(
            'Ingredientes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          if (_recipeIngredients.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Nenhum ingrediente cadastrado.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ..._buildIngredientCards(),
          const SizedBox(height: 20),
          _buildCostSummary(context),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _editRecipe,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar receita'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(
            widget.category.icon,
            style: const TextStyle(fontSize: 54),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _recipe.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          widget.category.name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.restaurant_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Rendimento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '${_formatNumber(_recipe.yieldQuantity)} '
              '${_recipe.yieldUnit}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes_rounded),
                const SizedBox(width: 10),
                Text(
                  'Observação',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _recipe.notes!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIngredientCards() {
    final cards = <Widget>[];

    for (final recipeIngredient
        in _recipeIngredients) {
      final ingredient = _findIngredient(
        recipeIngredient.ingredientId,
      );

      if (ingredient == null) {
        continue;
      }

      cards.add(
        RecipeDetailIngredientCard(
          ingredient: ingredient,
          recipeIngredient: recipeIngredient,
          cost: _ingredientCost(recipeIngredient),
        ),
      );
    }

    return cards;
  }

  Widget _buildCostSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _DetailRow(
              label: 'Custo total',
              value: _formatMoney(_totalCost),
            ),
            const Divider(height: 24),
            _DetailRow(
              label: 'Custo por ${_recipe.yieldUnit}',
              value: _formatMoney(_costPerYield),
              emphasized: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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