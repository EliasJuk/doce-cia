import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.visiblePageCount = 3,
    super.key,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  // Quantidade de páginas centrais exibidas quando existem
  // muitas páginas.
  final int visiblePageCount;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final pageItems = _buildPageItems();

    return SafeArea(
      top: false,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavigationButton(
                tooltip: 'Página anterior',
                icon: Icons.chevron_left_rounded,
                enabled: currentPage > 1,
                onPressed: () {
                  onPageChanged(currentPage - 1);
                },
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: pageItems.map((item) {
                    if (item == null) {
                      return const SizedBox(
                        width: 24,
                        height: 36,
                        child: Center(
                          child: Text('…'),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                      ),
                      child: _PageButton(
                        page: item,
                        selected: item == currentPage,
                        onPressed: () {
                          onPageChanged(item);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 4),
              _NavigationButton(
                tooltip: 'Próxima página',
                icon: Icons.chevron_right_rounded,
                enabled: currentPage < totalPages,
                onPressed: () {
                  onPageChanged(currentPage + 1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<int?> _buildPageItems() {
    // Até cinco páginas cabem confortavelmente na maioria
    // das telas de celular.
    if (totalPages <= 5) {
      return List<int>.generate(
        totalPages,
        (index) => index + 1,
      );
    }

    final items = <int?>[1];

    var start = currentPage - 1;
    var end = currentPage + 1;

    if (start < 2) {
      start = 2;
      end = 4;
    }

    if (end > totalPages - 1) {
      end = totalPages - 1;
      start = totalPages - 3;
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

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.page,
    required this.selected,
    required this.onPressed,
  });

  final int page;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return SizedBox(
        width: 36,
        height: 36,
        child: FilledButton(
          onPressed: null,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            disabledBackgroundColor:
                Theme.of(context).colorScheme.primary,
            disabledForegroundColor:
                Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text('$page'),
        ),
      );
    }

    return SizedBox(
      width: 36,
      height: 36,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text('$page'),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.tooltip,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      iconSize: 22,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: 36,
        height: 36,
      ),
    );
  }
}