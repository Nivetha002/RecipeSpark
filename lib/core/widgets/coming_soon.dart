import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Temporary body for screens built in a later part.
class ComingSoon extends StatelessWidget {
  final String title;
  final IconData icon;
  const ComingSoon({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.orange),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'This screen is built in Part 3.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
