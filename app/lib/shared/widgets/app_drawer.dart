import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.onHomeTap,
    required this.onThemesTap,
    required this.onAboutTap,
    super.key,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onThemesTap;
  final VoidCallback onAboutTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: const Text(
                      '🍪',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doce Cia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text('Receitas e custos'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Início'),
              onTap: onHomeTap,
            ),
            ListTile(
              leading: const Icon(Icons.palette_rounded),
              title: const Text('Temas'),
              onTap: onThemesTap,
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Sobre'),
              onTap: onAboutTap,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
