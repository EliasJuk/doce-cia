import 'package:flutter/material.dart';

import '../../models/ingredient/ingredient.dart';
import '../../models/ingredient/ingredient_unit.dart';
import '../../repositories/ingredient_repository.dart';

class IngredientFormPage extends StatefulWidget {
  const IngredientFormPage({
    this.ingredient,
    super.key,
  });

  final Ingredient? ingredient;

  @override
  State<IngredientFormPage> createState() => _IngredientFormPageState();
}

class _IngredientFormPageState extends State<IngredientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = IngredientRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  late IngredientUnit _selectedUnit;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final ingredient = widget.ingredient;

    _nameController = TextEditingController(text: ingredient?.name ?? '');
    _priceController = TextEditingController(
      text: ingredient == null
          ? ''
          : ingredient.purchasePrice.toStringAsFixed(2).replaceAll('.', ','),
    );
    _quantityController = TextEditingController(
      text: ingredient == null
          ? ''
          : ingredient.purchaseQuantity.toString().replaceAll('.', ','),
    );
    _notesController = TextEditingController(text: ingredient?.notes ?? '');
    _selectedUnit = ingredient == null
        ? IngredientUnit.gram
        : IngredientUnit.fromSymbol(ingredient.purchaseUnit);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _parseNumber(String value) {
    var normalized = value.trim();

    if (normalized.contains(',') && normalized.contains('.')) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    } else {
      normalized = normalized.replaceAll(',', '.');
    }

    return double.tryParse(normalized);
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Campo obrigatório' : null;
  }

  String? _positiveNumber(String? value) {
    final number = value == null ? null : _parseNumber(value);
    return number == null || number <= 0
        ? 'Informe um valor maior que zero'
        : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final now = DateTime.now();
      final quantity = _parseNumber(_quantityController.text)!;

      final ingredient = Ingredient(
        id: widget.ingredient?.id,
        name: _nameController.text.trim(),
        purchasePrice: _parseNumber(_priceController.text)!,
        purchaseQuantity: quantity,
        purchaseUnit: _selectedUnit.symbol,
        baseQuantity: _selectedUnit.toBaseQuantity(quantity),
        baseUnit: _selectedUnit.baseUnit,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.ingredient?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.ingredient == null) {
        await _repository.insert(ingredient);
      } else {
        await _repository.update(ingredient);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.ingredient != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar ingrediente' : 'Novo ingrediente'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex.: Farinha de trigo',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Preço pago',
                  hintText: 'Ex.: 12,00',
                  prefixText: 'R\$ ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: _positiveNumber,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Quantidade comprada',
                  hintText: 'Ex.: 5',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
                validator: _positiveNumber,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<IngredientUnit>(
                value: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unidade',
                  prefixIcon: Icon(Icons.straighten_rounded),
                ),
                items: IngredientUnit.values.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text('${unit.label} (${unit.symbol})'),
                  );
                }).toList(),
                onChanged: _saving
                    ? null
                    : (unit) {
                        if (unit != null) {
                          setState(() => _selectedUnit = unit);
                        }
                      },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observação',
                  hintText: 'Opcional',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Salvando...' : 'Salvar ingrediente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
