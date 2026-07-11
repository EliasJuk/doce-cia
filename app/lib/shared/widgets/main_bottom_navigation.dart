import 'package:flutter/material.dart';

class MainBottomNavigation extends StatelessWidget {
  const MainBottomNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2_rounded),
          label: 'Ingredientes',
        ),
        NavigationDestination(
          icon: Text(
            '🍪',
            style: TextStyle(fontSize: 27),
          ),
          selectedIcon: Text(
            '🍪',
            style: TextStyle(fontSize: 31),
          ),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book_rounded),
          label: 'Receitas',
        ),
      ],
    );
  }
}
