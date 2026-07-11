import 'package:flutter/material.dart';

import '../../models/categories/recipe_category.dart';
import '../../models/recipes/recipe.dart';
import '../../repositories/recipes/recipe_repository.dart';

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
  final _repository = RecipeRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _yieldQuantityController;
  late final TextEditingController _notesController;

  late String _selectedYieldUnit;

  bool _saving = false;

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yieldQuantityController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2).replaceAll('.', ',');
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoryId = widget.category.id;

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A coleção não possui um ID válido.'),
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

      if (_isEditing) {
        await _repository.update(recipe);
      } else {
        await _repository.insert(recipe);
      }

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
                textCapitalization:
                    TextCapitalization.sentences,
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
                textCapitalization:
                    TextCapitalization.sentences,
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