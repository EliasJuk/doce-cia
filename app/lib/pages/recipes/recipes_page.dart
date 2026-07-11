import 'package:flutter/material.dart';

import 'widgets/empty_recipes.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        EmptyRecipes(),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: null,
            child: Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }
}
