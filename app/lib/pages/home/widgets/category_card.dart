import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.emoji,
    required this.title,
    required this.recipeCount,
    required this.onTap,
    super.key,
  });

  final String emoji;
  final String title;
  final int recipeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final recipeLabel = recipeCount == 1 ? 'receita' : 'receitas';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Column(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 46),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '$recipeCount $recipeLabel',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
