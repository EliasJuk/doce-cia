import 'package:flutter/material.dart';

import 'widgets/category_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.onOpenRecipes,
    super.key,
  });

  final VoidCallback onOpenRecipes;

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Bom dia! 👋';
    }

    if (hour >= 12 && hour < 18) {
      return 'Boa tarde! 👋';
    }

    return 'Boa noite! 👋';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      children: [
        Image.asset(
          'assets/icons/cookie_logo.png',
          width: 250,
          height: 250,
          fit: BoxFit.contain,
        ),
        Text(
          'Doce Cia',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          greeting,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'O que vamos preparar hoje?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onOpenRecipes,
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text(
              'Explorar receitas',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: CategoryCard(
                emoji: '🍪',
                title: 'Cookies',
                recipeCount: 0,
                onTap: onOpenRecipes,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CategoryCard(
                emoji: '🥧',
                title: 'Tortas',
                recipeCount: 0,
                onTap: onOpenRecipes,
              ),
            ),
          ],
        ),
      ],
    );
  }
}