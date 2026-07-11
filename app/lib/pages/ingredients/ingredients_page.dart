import 'package:flutter/material.dart';

import 'widgets/empty_ingredients.dart';

class IngredientsPage extends StatelessWidget {
  const IngredientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        EmptyIngredients(),
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
