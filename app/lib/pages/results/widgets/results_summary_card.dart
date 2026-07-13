import 'package:flutter/material.dart';

class ResultsSummaryCard extends StatelessWidget {
  const ResultsSummaryCard({
    required this.grossRevenue,
    required this.productionCosts,
    required this.profit,
    required this.salesCount,
    super.key,
  });

  final double grossRevenue;
  final double productionCosts;
  final double profit;
  final int salesCount;

  String _money(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _ResultRow(
              label: 'Faturamento bruto',
              value: _money(grossRevenue),
            ),
            const Divider(height: 24),
            _ResultRow(
              label: 'Custos de produção',
              value: _money(productionCosts),
            ),
            const Divider(height: 24),
            _ResultRow(
              label: 'Lucro',
              value: _money(profit),
              emphasized: true,
            ),
            const Divider(height: 24),
            _ResultRow(
              label: 'Vendas registradas',
              value: '$salesCount',
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
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
        Expanded(child: Text(label, style: style)),
        Text(
          value,
          style: style?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
