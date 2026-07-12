import 'package:flutter/material.dart';

import '../../models/recipes/recipe.dart';
import '../../models/sales/sale.dart';
import '../../repositories/recipes/recipe_repository.dart';
import '../../repositories/sales/sale_repository.dart';

class SaleFormPage extends StatefulWidget {
  const SaleFormPage({
    this.sale,
    super.key,
  });

  final Sale? sale;

  @override
  State<SaleFormPage> createState() => _SaleFormPageState();
}

class _SaleFormPageState extends State<SaleFormPage> {
  final _formKey = GlobalKey<FormState>();

  final RecipeRepository _recipeRepository =
      RecipeRepository();

  final SaleRepository _saleRepository =
      SaleRepository();

  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _notesController;

  List<Recipe> _recipes = const [];
  Recipe? _selectedRecipe;

  late DateTime _saleDate;

  double _unitCost = 0;

  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _isEditing {
    return widget.sale != null;
  }

  @override
  void initState() {
    super.initState();

    final sale = widget.sale;

    _quantityController = TextEditingController(
      text: sale == null
          ? ''
          : _formatNumber(sale.quantity),
    );

    _unitPriceController = TextEditingController(
      text: sale == null
          ? ''
          : sale.unitPrice
              .toStringAsFixed(2)
              .replaceAll('.', ','),
    );

    _notesController = TextEditingController(
      text: sale?.notes ?? '',
    );

    _saleDate = sale?.saleDate ?? DateTime.now();
    _unitCost = sale?.unitCost ?? 0;

    _loadRecipes();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final recipes = await _recipeRepository.findAll();

      Recipe? selected;

      final saleRecipeId = widget.sale?.recipeId;

      if (saleRecipeId != null) {
        for (final recipe in recipes) {
          if (recipe.id == saleRecipeId) {
            selected = recipe;
            break;
          }
        }
      }

      if (selected == null && recipes.isNotEmpty) {
        selected = recipes.first;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _recipes = recipes;
        _selectedRecipe = selected;
      });

      if (!_isEditing && selected?.id != null) {
        await _updateUnitCost(selected!);
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

  Future<void> _updateUnitCost(
    Recipe recipe,
  ) async {
    final recipeId = recipe.id;

    if (recipeId == null) {
      return;
    }

    final cost = await _saleRepository
        .calculateRecipeUnitCost(recipeId);

    if (!mounted) {
      return;
    }

    setState(() {
      _unitCost = cost;
    });
  }

  double? _parseNumber(String value) {
    var normalized = value.trim();

    if (normalized.contains(',') &&
        normalized.contains('.')) {
      normalized = normalized
          .replaceAll('.', '')
          .replaceAll(',', '.');
    } else {
      normalized = normalized.replaceAll(',', '.');
    }

    return double.tryParse(normalized);
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String? _positiveNumber(String? value) {
    final number = value == null
        ? null
        : _parseNumber(value);

    if (number == null || number <= 0) {
      return 'Informe um valor maior que zero';
    }

    return null;
  }

  double get _quantity {
    return _parseNumber(_quantityController.text) ?? 0;
  }

  double get _unitPrice {
    return _parseNumber(_unitPriceController.text) ?? 0;
  }

  double get _totalValue {
    return _quantity * _unitPrice;
  }

  double get _totalCost {
    return _quantity * _unitCost;
  }

  double get _grossProfit {
    return _totalValue - _totalCost;
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _saleDate = selected;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final recipe = _selectedRecipe;

    if (recipe == null || recipe.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione uma receita.',
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

      final sale = Sale(
        id: widget.sale?.id,
        recipeId: recipe.id,
        recipeName: recipe.name,
        quantity: _quantity,
        unitPrice: _unitPrice,
        unitCost: _unitCost,
        saleDate: _saleDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.sale?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await _saleRepository.update(sale);
      } else {
        await _saleRepository.insert(sale);
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
            'Não foi possível salvar a venda: $error',
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
    final title = _isEditing
        ? 'Editar venda'
        : 'Nova venda';

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: FilledButton(
            onPressed: _loadRecipes,
            child: const Text('Tentar novamente'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_recipes.isEmpty) ...[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Cadastre uma receita antes de registrar uma venda.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ] else ...[
                DropdownButtonFormField<Recipe>(
                  initialValue: _selectedRecipe,
                  decoration: const InputDecoration(
                    labelText: 'Receita',
                    prefixIcon: Icon(
                      Icons.menu_book_outlined,
                    ),
                  ),
                  items: _recipes.map((recipe) {
                    return DropdownMenuItem<Recipe>(
                      value: recipe,
                      child: Text(recipe.name),
                    );
                  }).toList(),
                  onChanged: _saving
                      ? null
                      : (recipe) async {
                          if (recipe == null) {
                            return;
                          }

                          setState(() {
                            _selectedRecipe = recipe;
                          });

                          await _updateUnitCost(recipe);
                        },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  enabled: !_saving,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    hintText: 'Ex.: 10',
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
                TextFormField(
                  controller: _unitPriceController,
                  enabled: !_saving,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor unitário',
                    hintText: 'Ex.: 4,00',
                    prefixText: 'R\$ ',
                    prefixIcon: Icon(
                      Icons.payments_outlined,
                    ),
                  ),
                  validator: _positiveNumber,
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _saving ? null : _selectDate,
                  borderRadius: BorderRadius.circular(18),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data',
                      prefixIcon: Icon(
                        Icons.calendar_month_outlined,
                      ),
                    ),
                    child: Text(
                      _formatDate(_saleDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  enabled: !_saving,
                  maxLines: 3,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Observação',
                    hintText: 'Ex.: Encomenda da Ana',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(
                      Icons.notes_rounded,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Custo unitário',
                          value: _money(_unitCost),
                        ),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          label: 'Custo total',
                          value: _money(_totalCost),
                        ),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          label: 'Valor da venda',
                          value: _money(_totalValue),
                        ),
                        const Divider(height: 24),
                        _SummaryRow(
                          label: 'Resultado bruto',
                          value: _money(_grossProfit),
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
                        : 'Salvar venda',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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