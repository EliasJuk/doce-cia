import 'package:flutter/material.dart';

import '../../models/categories/recipe_category.dart';
import '../../models/recipes/recipe.dart';
import '../../repositories/recipes/recipe_repository.dart';
import '../../shared/widgets/pagination_bar.dart';
import 'recipe_details_page.dart';
import 'recipe_form_page.dart';

class CategoryRecipesPage extends StatefulWidget {
  const CategoryRecipesPage({
    required this.category,
    super.key,
  });

  final RecipeCategory category;

  @override
  State<CategoryRecipesPage> createState() =>
      _CategoryRecipesPageState();
}

class _CategoryRecipesPageState
    extends State<CategoryRecipesPage> {
  static const int _pageSize = 20;

  final RecipeRepository _repository =
      RecipeRepository();

  final ScrollController _scrollController =
      ScrollController();

  List<Recipe> _recipes = const [];

  int _currentPage = 1;
  int _totalItems = 0;

  bool _loading = true;
  String? _error;

  int get _totalPages {
    if (_totalItems == 0) {
      return 0;
    }

    return (_totalItems / _pageSize).ceil();
  }

  int get _currentOffset {
    return (_currentPage - 1) * _pageSize;
  }

  double get _floatingButtonBottom {
    return _totalPages > 1 ? 78 : 20;
  }

  double get _listBottomPadding {
    return _totalPages > 1 ? 140 : 100;
  }

  @override
  void initState() {
    super.initState();

    _loadRecipes();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _loadRecipes() async {
    final categoryId = widget.category.id;

    if (categoryId == null) {
      setState(() {
        _loading = false;
        _error =
            'A coleção não possui um ID válido.';
      });

      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final totalItems =
          await _repository.countByCategory(
        categoryId,
      );

      final totalPages = totalItems == 0
          ? 0
          : (totalItems / _pageSize).ceil();

      if (totalPages == 0) {
        _currentPage = 1;
      } else if (_currentPage > totalPages) {
        _currentPage = totalPages;
      }

      final recipes =
          await _repository.findPageByCategory(
        categoryId: categoryId,
        limit: _pageSize,
        offset: (_currentPage - 1) * _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _totalItems = totalItems;
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

  Future<void> _loadPage(int page) async {
    final categoryId = widget.category.id;

    if (categoryId == null ||
        _loading ||
        page < 1 ||
        page > _totalPages ||
        page == _currentPage) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final recipes =
          await _repository.findPageByCategory(
        categoryId: categoryId,
        limit: _pageSize,
        offset: (page - 1) * _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPage = page;
        _recipes = recipes;
      });

      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          0,
          duration: const Duration(
            milliseconds: 250,
          ),
          curve: Curves.easeOut,
        );
      }
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
        title: Text(
          widget.category.name,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadRecipes,
                  child: _buildContent(context),
                ),
              ),
              if (!_loading &&
                  _error == null &&
                  _totalPages > 1)
                PaginationBar(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onPageChanged: _loadPage,
                ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: _floatingButtonBottom,
            child: FloatingActionButton(
              heroTag:
                  'add_recipe_${widget.category.id}',
              onPressed: _loading
                  ? null
                  : () {
                      _openRecipeForm();
                    },
              child: const Icon(
                Icons.add_rounded,
              ),
            ),
          ),
        ],
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
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color:
                Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar as receitas.',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadRecipes,
            child: const Text(
              'Tentar novamente',
            ),
          ),
        ],
      );
    }

    if (_totalItems == 0) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 100),
          Text(
            widget.category.icon,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 72,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Nenhuma receita cadastrada',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione a primeira receita da coleção '
            '${widget.category.name}.',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        _listBottomPadding,
      ),
      itemCount: 1 + _recipes.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          final firstItem = _currentOffset + 1;

          final lastItem =
              (_currentOffset + _recipes.length)
                  .clamp(0, _totalItems);

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Text(
              'Exibindo $firstItem–$lastItem '
              'de $_totalItems receitas',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodySmall,
            ),
          );
        }

        final recipe = _recipes[index - 1];

        return Card(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),
          child: ListTile(
            leading: Text(
              widget.category.icon,
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
            title: Text(
              recipe.name,
            ),
            subtitle: Text(
              '${recipe.yieldQuantity} '
              '${recipe.yieldUnit}',
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