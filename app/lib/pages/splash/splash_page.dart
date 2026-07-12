import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/theme_controller.dart';
import '../shell/app_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    required this.themeController,
    super.key,
  });

  final ThemeController themeController;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AppShell(
            themeController: widget.themeController,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF8094),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 210,
                height: 210,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9AAA),
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icons/cookie_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Doce Cia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Receitas que adoçam seus momentos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFF1F4),
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}