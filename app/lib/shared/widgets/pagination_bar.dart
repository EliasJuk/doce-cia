import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.visiblePageCount = 5,
    super.key,
  });

  // As páginas são baseadas em 1:
  // primeira página = 1.
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int visiblePageCount;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final items = _buildPageItems();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          10,
          12,
          16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Página anterior',
              onPressed: currentPage > 1
                  ? () {
                      onPageChanged(currentPage - 1);
                    }
                  : null,
              icon: const Icon(
                Icons.chevron_left_rounded,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: items.map((item) {
                    if (item == null) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: Text('...'),
                      );
                    }

                    final selected = item == currentPage;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                      ),
                      child: selected
                          ? FilledButton(
                              onPressed: null,
                              style: FilledButton.styleFrom(
                                disabledBackgroundColor:
                                    Theme.of(context)
                                        .colorScheme
                                        .primary,
                                disabledForegroundColor:
                                    Theme.of(context)
                                        .colorScheme
                                        .onPrimary,
                                minimumSize: const Size(42, 42),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text('$item'),
                            )
                          : TextButton(
                              onPressed: () {
                                onPageChanged(item);
                              },
                              style: TextButton.styleFrom(
                                minimumSize: const Size(42, 42),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text('$item'),
                            ),
                    );
                  }).toList(),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Próxima página',
              onPressed: currentPage < totalPages
                  ? () {
                      onPageChanged(currentPage + 1);
                    }
                  : null,
              icon: const Icon(
                Icons.chevron_right_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<int?> _buildPageItems() {
    if (totalPages <= visiblePageCount + 2) {
      return List<int>.generate(
        totalPages,
        (index) => index + 1,
      );
    }

    final items = <int?>[1];

    final half = visiblePageCount ~/ 2;

    var start = currentPage - half;
    var end = currentPage + half;

    if (visiblePageCount.isEven) {
      end -= 1;
    }

    if (start < 2) {
      start = 2;
      end = start + visiblePageCount - 1;
    }

    if (end > totalPages - 1) {
      end = totalPages - 1;
      start = end - visiblePageCount + 1;
    }

    if (start > 2) {
      items.add(null);
    }

    for (var page = start; page <= end; page++) {
      items.add(page);
    }

    if (end < totalPages - 1) {
      items.add(null);
    }

    items.add(totalPages);

    return items;
  }
}