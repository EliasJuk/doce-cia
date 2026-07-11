import 'package:flutter/material.dart';

import '../../core/theme/theme_controller.dart';
import 'widgets/theme_option_tile.dart';

class ThemesPage extends StatelessWidget {
  const ThemesPage({
    required this.themeController,
    super.key,
  });

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Temas'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Aparência do aplicativo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha como o Doce Cia deve aparecer.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ThemeOptionTile(
                title: 'Seguir o sistema',
                subtitle: 'Usa o tema configurado no dispositivo',
                icon: Icons.settings_suggest_outlined,
                value: ThemeMode.system,
                groupValue: themeController.themeMode,
                onChanged: themeController.setThemeMode,
              ),
              const SizedBox(height: 12),
              ThemeOptionTile(
                title: 'Claro',
                subtitle: 'Fundo creme e cores suaves',
                icon: Icons.light_mode_outlined,
                value: ThemeMode.light,
                groupValue: themeController.themeMode,
                onChanged: themeController.setThemeMode,
              ),
              const SizedBox(height: 12),
              ThemeOptionTile(
                title: 'Escuro',
                subtitle: 'Tons de chocolate e rosa suave',
                icon: Icons.dark_mode_outlined,
                value: ThemeMode.dark,
                groupValue: themeController.themeMode,
                onChanged: themeController.setThemeMode,
              ),
            ],
          ),
        );
      },
    );
  }
}
