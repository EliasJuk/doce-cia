import 'package:flutter/material.dart';

import '../../models/categories/recipe_category.dart';
import '../../models/recipes/recipe.dart';
import '../../repositories/recipes/recipe_repository.dart';
import 'recipe_form_page.dart';
import 'recipe_details_page.dart';

class CategoryRecipesPage extends StatefulWidget {
  const CategoryRecipesPage({
    required this.category,
    super.key,
  });

  final RecipeCategory category;

  @override
  State<CategoryRecipesPage> createState() => _CategoryRecipesPageState();
}

class _CategoryRecipesPageState extends State<CategoryRecipesPage> {
  final RecipeRepository _repository = RecipeRepository();

  List<Recipe> _recipes = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final categoryId = widget.category.id;

    if (categoryId == null) {
      setState(() {
        _loading = false;
        _error = 'A coleção não possui um ID válido.';
      });

      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final recipes = await _repository.findByCategory(categoryId);

      if (!mounted) {
        return;
      }

      setState(() {
        _recipes = recipes;
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

  Future<void> _openRecipeForm([
    Recipe? recipe,
  ]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecipeFormPage(
          category: widget.category,
          recipe: recipe,
        ),
      ),
    );

    if (changed == true) {
      await _loadRecipes();
    }
  }

  Future<void> _openRecipeDetails(
    Recipe recipe,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecipeDetailsPage(
          category: widget.category,
          recipe: recipe,
        ),
      ),
    );

    await _loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecipes,
        child: _buildContent(context),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_recipe_${widget.category.id}',
        onPressed: _loading
            ? null
            : () {
                _openRecipeForm();
              },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar as receitas.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadRecipes,
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    if (_recipes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 100),
          Text(
            widget.category.icon,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 72),
          ),
          const SizedBox(height: 18),
          Text(
            'Nenhuma receita cadastrada',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione a primeira receita da coleção '
            '${widget.category.name}.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Text(
              widget.category.icon,
              style: const TextStyle(fontSize: 30),
            ),
            title: Text(recipe.name),
            subtitle: Text(
              '${recipe.yieldQuantity} ${recipe.yieldUnit}',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: () {
              _openRecipeDetails(recipe);
            },
          ),
        );
      },
    );
  }
}