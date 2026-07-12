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
  static const int _pageSize = 30;

  final SaleRepository _repository = SaleRepository();
  final ScrollController _scrollController = ScrollController();

  List<Sale> _sales = const [];

  SalesTotals _totals = const SalesTotals(
    totalSales: 0,
    totalProfit: 0,
  );

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  int _offset = 0;
  String? _error;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);
    _reload();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();

    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    // Carrega a próxima página um pouco antes de chegar ao final.
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _loadingMore = false;
      _hasMore = true;
      _offset = 0;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _repository.findPage(
          limit: _pageSize,
          offset: 0,
        ),
        _repository.calculateTotals(),
      ]);

      final sales = results[0] as List<Sale>;
      final totals = results[1] as SalesTotals;

      if (!mounted) {
        return;
      }

      setState(() {
        _sales = sales;
        _totals = totals;
        _offset = sales.length;
        _hasMore = sales.length == _pageSize;
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

  Future<void> _loadMore() async {
    if (_loading ||
        _loadingMore ||
        !_hasMore ||
        _error != null) {
      return;
    }

    setState(() {
      _loadingMore = true;
    });

    try {
      final nextPage = await _repository.findPage(
        limit: _pageSize,
        offset: _offset,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _sales = [
          ..._sales,
          ...nextPage,
        ];

        _offset += nextPage.length;
        _hasMore = nextPage.length == _pageSize;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível carregar mais vendas: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingMore = false;
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
      await _reload();
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

    try {
      await _repository.delete(sale.id!);
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível excluir a venda: $error',
          ),
        ),
      );
    }
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
        onRefresh: _reload,
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
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar as vendas.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _reload,
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    if (_sales.isEmpty) {
      return ListView(
        controller: _scrollController,
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

    /*
     * Temos:
     * 1 item para o resumo;
     * N itens de vendas;
     * 1 item opcional para o carregamento final.
     */
    final itemCount =
        1 + _sales.length + (_loadingMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _buildSummary(),
          );
        }

        final saleIndex = index - 1;

        if (saleIndex < _sales.length) {
          final sale = _sales[saleIndex];

          return SaleCard(
            sale: sale,
            onEdit: () {
              _openForm(sale);
            },
            onDelete: () {
              _deleteSale(sale);
            },
          );
        }

        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _SalesSummaryRow(
              label: 'Total vendido',
              value: _money(_totals.totalSales),
            ),
            const Divider(height: 24),
            _SalesSummaryRow(
              label: 'Resultado bruto',
              value: _money(_totals.totalProfit),
              emphasized: true,
            ),
          ],
        ),
      ),
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