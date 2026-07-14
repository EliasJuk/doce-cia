import 'package:flutter/material.dart';

import '../../models/sales/sale.dart';
import '../../repositories/sales/sale_repository.dart';
import '../../shared/widgets/month_year_filter.dart';
import '../../shared/widgets/pagination_bar.dart';
import 'sale_form_page.dart';
import 'widgets/sale_card.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  static const int _pageSize = 10;

  final SaleRepository _repository = SaleRepository();
  final ScrollController _scrollController = ScrollController();

  List<Sale> _sales = const [];
  List<int> _availableYears = const [];

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  int _currentPage = 1;
  int _totalItems = 0;

  bool _loading = true;
  String? _error;

  DateTime get _startDate {
    return DateTime(
      _selectedYear,
      _selectedMonth,
      1,
    );
  }

  DateTime get _endDate {
    return DateTime(
      _selectedYear,
      _selectedMonth + 1,
      1,
    );
  }

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

    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<Object>([
        _repository.findAvailableYears(),
        _repository.countByPeriod(
          startDate: _startDate,
          endDate: _endDate,
        ),
      ]);

      final availableYears = results[0] as List<int>;
      final totalItems = results[1] as int;

      final totalPages = totalItems == 0
          ? 0
          : (totalItems / _pageSize).ceil();

      if (totalPages == 0) {
        _currentPage = 1;
      } else if (_currentPage > totalPages) {
        _currentPage = totalPages;
      }

      final sales = await _repository.findPageByPeriod(
        startDate: _startDate,
        endDate: _endDate,
        limit: _pageSize,
        offset: (_currentPage - 1) * _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _availableYears = availableYears;
        _totalItems = totalItems;
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
      final sales = await _repository.findPageByPeriod(
        startDate: _startDate,
        endDate: _endDate,
        limit: _pageSize,
        offset: (page - 1) * _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPage = page;
        _sales = sales;
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

  Future<void> _changeMonth(int month) async {
    setState(() {
      _selectedMonth = month;
      _currentPage = 1;
    });

    await _loadData();
  }

  Future<void> _changeYear(int year) async {
    setState(() {
      _selectedYear = year;
      _currentPage = 1;
    });

    await _loadData();
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
      await _loadData();
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

    if (confirmed != true || sale.id == null) {
      return;
    }

    try {
      await _repository.delete(sale.id!);
      await _loadData();
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

  @override
  Widget build(BuildContext context) {
    final years = _availableYears.isEmpty
        ? [_selectedYear]
        : _availableYears;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendas'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  8,
                ),
                child: MonthYearFilter(
                  month: _selectedMonth,
                  year: _selectedYear,
                  availableYears: years,
                  onMonthChanged: _changeMonth,
                  onYearChanged: _changeYear,
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
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
              heroTag: 'add_sale',
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
          const SizedBox(height: 80),
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
            onPressed: _loadData,
            child: const Text(
              'Tentar novamente',
            ),
          ),
        ],
      );
    }

    if (_totalItems == 0) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.point_of_sale_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'Nenhuma venda neste período',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Altere o mês e o ano ou registre uma nova venda.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        _listBottomPadding,
      ),
      itemCount: 1 + _sales.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          final firstItem = _currentOffset + 1;

          final lastItem =
              (_currentOffset + _sales.length)
                  .clamp(0, _totalItems);

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Text(
              'Exibindo $firstItem–$lastItem '
              'de $_totalItems vendas',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }

        final sale = _sales[index - 1];

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
    );
  }
}