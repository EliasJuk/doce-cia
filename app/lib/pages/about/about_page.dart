import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: const Text(
                  '🍪',
                  style: TextStyle(fontSize: 46),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Doce Cia',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Receitas e custos para confeitaria.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              const Text('Versão 0.1.0'),
            ],
          ),
        ),
      ),
    );
  }
}
