import 'package:flutter/material.dart';

import '../../core/theme/theme_controller.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../shared/widgets/main_bottom_navigation.dart';
import '../about/about_page.dart';
import '../home/home_page.dart';
import '../ingredients/ingredients_page.dart';
import '../recipes/recipes_page.dart';
import '../themes/themes_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.themeController,
    super.key,
  });

  final ThemeController themeController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 1;

  final List<Widget> _pages = const [
    IngredientsPage(),
    HomePage(),
    RecipesPage(),
  ];

  final List<String> _titles = const [
    'Ingredientes',
    'Doce Cia',
    'Receitas',
  ];

  void _selectBottomPage(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openHome() {
    Navigator.of(context).pop();
    _selectBottomPage(1);
  }

  void _openThemes() {
    Navigator.of(context).pop();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ThemesPage(
          themeController: widget.themeController,
        ),
      ),
    );
  }

  void _openAbout() {
    Navigator.of(context).pop();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AboutPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      drawer: AppDrawer(
        onHomeTap: _openHome,
        onThemesTap: _openThemes,
        onAboutTap: _openAbout,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: MainBottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectBottomPage,
      ),
    );
  }
}
