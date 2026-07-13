import 'package:flutter/material.dart';

import '../../models/results/sales_by_recipe.dart';
import '../../models/results/sales_period_totals.dart';
import '../../repositories/sales/sale_repository.dart';
import '../../shared/widgets/month_year_filter.dart';
import 'widgets/results_summary_card.dart';
import 'widgets/sales_by_recipe_chart.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final SaleRepository _repository = SaleRepository();

  List<int> _availableYears = const [];
  List<SalesByRecipe> _salesByRecipe = const [];

  SalesPeriodTotals _totals = const SalesPeriodTotals(
    grossRevenue: 0,
    productionCosts: 0,
    profit: 0,
    salesCount: 0,
  );

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool _loading = true;
  String? _error;

  DateTime get _startDate =>
      DateTime(_selectedYear, _selectedMonth, 1);

  DateTime get _endDate =>
      DateTime(_selectedYear, _selectedMonth + 1, 1);

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<Object>([
        _repository.findAvailableYears(),
        _repository.calculateTotalsByPeriod(
          startDate: _startDate,
          endDate: _endDate,
        ),
        _repository.findSalesByRecipeByPeriod(
          startDate: _startDate,
          endDate: _endDate,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _availableYears = results[0] as List<int>;
        _totals = results[1] as SalesPeriodTotals;
        _salesByRecipe = results[2] as List<SalesByRecipe>;
      });
    } catch (error) {
      if (!mounted) return;

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
    });

    await _loadResults();
  }

  Future<void> _changeYear(int year) async {
    setState(() {
      _selectedYear = year;
    });

    await _loadResults();
  }

  @override
  Widget build(BuildContext context) {
    final years = _availableYears.isEmpty
        ? [_selectedYear]
        : _availableYears;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadResults,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            MonthYearFilter(
              month: _selectedMonth,
              year: _selectedYear,
              availableYears: years,
              onMonthChanged: _changeMonth,
              onYearChanged: _changeYear,
            ),
            const SizedBox(height: 18),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              _buildError(context)
            else ...[
              ResultsSummaryCard(
                grossRevenue: _totals.grossRevenue,
                productionCosts: _totals.productionCosts,
                profit: _totals.profit,
                salesCount: _totals.salesCount,
              ),
              const SizedBox(height: 18),
              SalesByRecipeChart(
                items: _salesByRecipe,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar os resultados.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadResults,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
