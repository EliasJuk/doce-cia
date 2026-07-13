import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../models/results/sales_by_recipe.dart';

class SalesByRecipeChart extends StatelessWidget {
  const SalesByRecipeChart({
    required this.items,
    super.key,
  });

  final List<SalesByRecipe> items;

  List<SalesByRecipe> get _chartItems {
    if (items.length <= 5) return items;

    final topItems = items.take(5).toList();
    final others = items.skip(5).fold<double>(
          0,
          (total, item) => total + item.quantity,
        );

    return [
      ...topItems,
      SalesByRecipe(
        recipeName: 'Outros',
        quantity: others,
      ),
    ];
  }

  String _number(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final data = _chartItems;

    if (data.isEmpty) {
      return const Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Não há vendas neste período para gerar o gráfico.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final total = data.fold<double>(
      0,
      (sum, item) => sum + item.quantity,
    );

    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.secondaryContainer,
      Theme.of(context).colorScheme.tertiaryContainer,
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produtos mais vendidos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Comparação pela quantidade vendida.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 42,
                  sectionsSpace: 2,
                  sections: List.generate(
                    data.length,
                    (index) {
                      final item = data[index];
                      final percentage = total <= 0
                          ? 0
                          : (item.quantity / total) * 100;

                      return PieChartSectionData(
                        value: item.quantity,
                        color: colors[index % colors.length],
                        radius: 70,
                        title: '${percentage.toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            ...List.generate(
              data.length,
              (index) {
                final item = data[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item.recipeName)),
                      Text(
                        _number(item.quantity),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
