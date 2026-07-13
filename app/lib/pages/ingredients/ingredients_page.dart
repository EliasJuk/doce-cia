import 'package:flutter/material.dart';

import '../../models/ingredient/ingredient.dart';
import '../../repositories/ingredient_repository.dart';
import '../../shared/widgets/pagination_bar.dart';
import 'ingredient_form_page.dart';
import 'widgets/empty_ingredients.dart';
import 'widgets/ingredient_card.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({
    this.databaseRevision = 0,
    super.key,
  });

  final int databaseRevision;

  @override
  State<IngredientsPage> createState() =>
      _IngredientsPageState();
}

class _IngredientsPageState
    extends State<IngredientsPage> {
  static const int _pageSize = 20;

  final IngredientRepository _repository =
      IngredientRepository();

  final ScrollController _scrollController =
      ScrollController();

  List<Ingredient> _ingredients = const [];

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

  @override
  void initState() {
    super.initState();

    _load();
  }

  @override
  void didUpdateWidget(
    covariant IngredientsPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.databaseRevision !=
        widget.databaseRevision) {
      _load();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final totalItems = await _repository.countAll();

      final totalPages = totalItems == 0
          ? 0
          : (totalItems / _pageSize).ceil();

      if (totalPages == 0) {
        _currentPage = 1;
      } else if (_currentPage > totalPages) {
        _currentPage = totalPages;
      }

      final ingredients = await _repository.findPage(
        limit: _pageSize,
        offset: (_currentPage - 1) * _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _totalItems = totalItems;
        _ingredients = ingredients;
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
    if (_loading ||
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
      final ingredients = await _repository.findPage(
        limit: _pageSize,
        offset: (page - 1) * _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPage = page;
        _ingredients = ingredients;
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

  Future<void> _openForm([
    Ingredient? ingredient,
  ]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => IngredientFormPage(
          ingredient: ingredient,
        ),
      ),
    );

    if (changed == true) {
      await _load();
    }
  }

  Future<void> _delete(
    Ingredient ingredient,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Excluir ingrediente?',
          ),
          content: Text(
            'O ingrediente "${ingredient.name}" será removido.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        ingredient.id == null) {
      return;
    }

    try {
      await _repository.delete(
        ingredient.id!,
      );

      // Caso o último item da última página seja excluído,
      // o método ajustará automaticamente a página atual.
      await _load();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível excluir. '
            'O ingrediente pode estar em uma receita.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
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

        // O botão fica acima da barra de paginação.
        Positioned(
          right: 20,
          bottom: _totalPages > 1 ? 76 : 20,
          child: FloatingActionButton(
            heroTag: 'add_ingredient',
            onPressed: _loading
                ? null
                : () {
                    _openForm();
                  },
            child: const Icon(
              Icons.add_rounded,
            ),
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
            'Não foi possível carregar os ingredientes.',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _load,
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
        children: const [
          SizedBox(
            height: 520,
            child: EmptyIngredients(),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ),
      itemCount: 1 + _ingredients.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          final firstItem = _currentOffset + 1;

          final lastItem =
              (_currentOffset + _ingredients.length)
                  .clamp(0, _totalItems);

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Text(
              'Exibindo $firstItem–$lastItem '
              'de $_totalItems ingredientes',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodySmall,
            ),
          );
        }

        final ingredient =
            _ingredients[index - 1];

        return IngredientCard(
          ingredient: ingredient,
          onEdit: () {
            _openForm(ingredient);
          },
          onDelete: () {
            _delete(ingredient);
          },
        );
      },
    );
  }
}