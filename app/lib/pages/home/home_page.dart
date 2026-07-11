import 'package:flutter/material.dart';

import 'widgets/category_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greeting() {
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
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        children: [
          Text(
            _greeting(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'O que vamos preparar hoje?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: CategoryCard(
                  emoji: '🍪',
                  title: 'Cookies',
                  recipeCount: 8,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: CategoryCard(
                  emoji: '🥧',
                  title: 'Tortas',
                  recipeCount: 5,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
