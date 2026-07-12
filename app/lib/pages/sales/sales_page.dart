import 'package:flutter/material.dart';

import '../../models/sales/sale.dart';
import '../../repositories/sales/sale_repository.dart';
import 'sale_form_page.dart';
import 'widgets/sale_card.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final SaleRepository _repository =
      SaleRepository();

  List<Sale> _sales = const [];

  bool _loading = true;
  String? _error;

  double get _totalSales {
    return _sales.fold<double>(
      0,
      (total, sale) => total + sale.totalValue,
    );
  }

  double get _totalProfit {
    return _sales.fold<double>(
      0,
      (total, sale) => total + sale.grossProfit,
    );
  }

  @override
  void initState() {
    super.initState();

    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final sales = await _repository.findAll();

      if (!mounted) {
        return;
      }

      setState(() {
        _sales = sales;
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
    Sale? sale,
  ]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SaleFormPage(
          sale: sale,
        ),
      ),
    );

    if (changed == true) {
      await _loadSales();
    }
  }

  Future<void> _deleteSale(
    Sale sale,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir venda?'),
          content: Text(
            'A venda de "${sale.recipeName}" será removida.',
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

    if (confirmed != true || sale.id == null) {
      return;
    }

    await _repository.delete(sale.id!);
    await _loadSales();
  }

  String _money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendas'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSales,
        child: _buildContent(context),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_sale',
        onPressed: _loading
            ? null
            : () {
                _openForm();
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
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar as vendas.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadSales,
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    if (_sales.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.point_of_sale_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'Nenhuma venda registrada',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Use o botão + para registrar a primeira venda.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _SalesSummaryRow(
                  label: 'Total vendido',
                  value: _money(_totalSales),
                ),
                const Divider(height: 24),
                _SalesSummaryRow(
                  label: 'Resultado bruto',
                  value: _money(_totalProfit),
                  emphasized: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        ..._sales.map(
          (sale) {
            return SaleCard(
              sale: sale,
              onEdit: () {
                _openForm(sale);
              },
              onDelete: () {
                _deleteSale(sale);
              },
            );
          },
        ),
      ],
    );
  }
}

class _SalesSummaryRow extends StatelessWidget {
  const _SalesSummaryRow({
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