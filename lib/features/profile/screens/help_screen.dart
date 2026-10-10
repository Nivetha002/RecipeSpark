import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    (
      'How does the match percentage work?',
      'It is the share of a recipe\'s required ingredients that you have selected. Optional ingredients and pantry staples such as salt and oil are not counted.'
    ),
    (
      'Where is my data stored?',
      'Favourites, cooking history, your shopping list and your name are stored on this device only.'
    ),
    (
      'Is the AI assistant a real AI?',
      'Not yet. It runs in offline demo mode with built-in tips and your recipe catalog. The app is ready for a real AI service to be connected later.'
    ),
    (
      'How do I find recipes from what I have?',
      'Select ingredients on Home or in Select Ingredients, then tap Find Recipes.'
    ),
    (
      'Can I sign in?',
      'Accounts are not available yet. You can use every feature as a guest.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Help & Support'), backgroundColor: AppColors.cream),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final f in _faqs)
            Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                shape: const Border(),
                title: Text(f.$1,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                expandedAlignment: Alignment.centerLeft,
                children: [Text(f.$2)],
              ),
            ),
        ],
      ),
    );
  }
}
