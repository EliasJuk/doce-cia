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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 46)),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '$recipeCount receitas',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}