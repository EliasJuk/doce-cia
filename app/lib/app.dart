import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'pages/shell/app_shell.dart';

class DoceCiaApp extends StatefulWidget {
  const DoceCiaApp({super.key});

  @override
  State<DoceCiaApp> createState() => _DoceCiaAppState();
}

class _DoceCiaAppState extends State<DoceCiaApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Doce Cia',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeController.themeMode,
          home: AppShell(
            themeController: _themeController,
          ),
        );
      },
    );
  }
}