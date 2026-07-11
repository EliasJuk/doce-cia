import 'package:flutter/material.dart';

import '../../models/categories/recipe_category.dart';
import '../../repositories/categories/category_repository.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({
    this.category,
    super.key,
  });

  final RecipeCategory? category;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = CategoryRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _iconController;

  bool _saving = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.category?.name ?? '',
    );

    _iconController = TextEditingController(
      text: widget.category?.icon ?? '🍰',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final now = DateTime.now();

      final category = RecipeCategory(
        id: widget.category?.id,
        name: _nameController.text.trim(),
        icon: _iconController.text.trim(),
        createdAt: widget.category?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await _repository.update(category);
      } else {
        await _repository.insert(category);
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
            'Não foi possível salvar a coleção: $error',
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
          _isEditing ? 'Editar coleção' : 'Nova coleção',
        ),
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
                  hintText: 'Ex.: Brownies',
                  prefixIcon: Icon(Icons.folder_outlined),
                ),
                validator: _requiredField,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _iconController,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Ícone',
                  hintText: 'Ex.: 🍰',
                  prefixIcon: Icon(Icons.emoji_emotions_outlined),
                ),
                validator: _requiredField,
              ),
              const SizedBox(height: 12),
              Text(
                ' ',
                style: Theme.of(context).textTheme.bodyMedium,
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
                  _saving ? 'Salvando...' : 'Salvar coleção',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}