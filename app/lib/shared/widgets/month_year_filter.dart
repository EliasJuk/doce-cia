import 'package:flutter/material.dart';

class MonthYearFilter extends StatelessWidget {
  const MonthYearFilter({
    required this.month,
    required this.year,
    required this.availableYears,
    required this.onMonthChanged,
    required this.onYearChanged,
    super.key,
  });

  final int month;
  final int year;
  final List<int> availableYears;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  static const _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril',
    'Maio', 'Junho', 'Julho', 'Agosto',
    'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                initialValue: month,
                decoration: const InputDecoration(
                  labelText: 'Mês',
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                ),
                items: List.generate(
                  12,
                  (index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text(_months[index]),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) onMonthChanged(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: year,
                decoration: const InputDecoration(labelText: 'Ano'),
                items: availableYears
                    .map(
                      (item) => DropdownMenuItem<int>(
                        value: item,
                        child: Text('$item'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onYearChanged(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
