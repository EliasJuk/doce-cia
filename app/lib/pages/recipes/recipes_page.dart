import 'package:flutter/material.dart';

import '../../models/categories/recipe_category.dart';
import '../../repositories/categories/category_repository.dart';
import 'category_form_page.dart';
import 'widgets/recipe_category_card.dart';
import 'category_recipes_page.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({
    this.databaseRevision = 0,
    super.key,
  });

  final int databaseRevision;

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final CategoryRepository _repository = CategoryRepository();

  List<RecipeCategory> _categories = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _loadCategories();
  }

  @override
  void didUpdateWidget(covariant RecipesPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.databaseRevision != widget.databaseRevision) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final categories = await _repository.findAll();

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
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

  Future<void> _openForm([
    RecipeCategory? category,
  ]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) {
          return CategoryFormPage(
            category: category,
          );
        },
      ),
    );

    if (changed == true) {
      await _loadCategories();
    }
  }

  Future<void> _deleteCategory(
    RecipeCategory category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir coleção?'),
          content: Text(
            'A coleção "${category.name}" será removida.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || category.id == null) {
      return;
    }

    try {
      await _repository.delete(category.id!);
      await _loadCategories();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível excluir a coleção: $error',
          ),
        ),
      );
    }
  }

  void _openCategory(
    RecipeCategory category,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryRecipesPage(
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadCategories,
          child: _buildContent(context),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            heroTag: 'add_recipe_category',
            onPressed: _loading
                ? null
                : () {
                    _openForm();
                  },
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
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
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar as coleções.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadCategories,
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    if (_categories.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.folder_outlined,
            size: 68,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'Nenhuma coleção cadastrada',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Crie coleções para organizar cookies, tortas e outras receitas.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];

        return RecipeCategoryCard(
          category: category,
          onOpen: () {
            _openCategory(category);
          },
          onEdit: () {
            _openForm(category);
          },
          onDelete: () {
            _deleteCategory(category);
          },
        );
      },
    );
  }
}