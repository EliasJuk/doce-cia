import 'package:flutter/material.dart';

import '../../models/ingredient/ingredient.dart';
import '../../repositories/ingredient_repository.dart';
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
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final _repository = IngredientRepository();

  List<Ingredient> _ingredients = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant IngredientsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.databaseRevision != widget.databaseRevision) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ingredients = await _repository.findAll();

      if (!mounted) return;
      setState(() => _ingredients = ingredients);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([Ingredient? ingredient]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => IngredientFormPage(ingredient: ingredient),
      ),
    );

    if (changed == true) await _load();
  }

  Future<void> _delete(Ingredient ingredient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir ingrediente?'),
        content: Text('O ingrediente "${ingredient.name}" será removido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || ingredient.id == null) return;

    try {
      await _repository.delete(ingredient.id!);
      await _load();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível excluir. O ingrediente pode estar em uma receita.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _load,
          child: _buildContent(context),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            heroTag: 'add_ingredient',
            onPressed: _loading ? null : () => _openForm(),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.error_outline_rounded, size: 64),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar os ingredientes.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _load,
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    if (_ingredients.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 520, child: EmptyIngredients()),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = _ingredients[index];

        return IngredientCard(
          ingredient: ingredient,
          onEdit: () => _openForm(ingredient),
          onDelete: () => _delete(ingredient),
        );
      },
    );
  }
}
