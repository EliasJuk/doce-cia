import 'package:flutter/material.dart';

import '../../../models/sales/sale.dart';

class SaleCard extends StatelessWidget {
  const SaleCard({
    required this.sale,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Sale sale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _number(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            16,
            8,
            16,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(
                  Icons.point_of_sale_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.recipeName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_number(sale.quantity)} × '
                      '${_money(sale.unitPrice)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_date(sale.saleDate)} • '
                      'Total ${_money(sale.totalValue)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Resultado bruto: '
                      '${_money(sale.grossProfit)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  }

                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir'),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}