import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/food_image.dart';
import '../../recipes/data/recipe_catalog.dart';
import '../../recipes/screens/recipe_details_screen.dart';
import '../state/cooking_history_provider.dart';

class CookingHistoryScreen extends StatelessWidget {
  const CookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<CookingHistoryProvider>().entries;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Cooking History'), backgroundColor: AppColors.cream),
      body: entries.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🍳', style: TextStyle(fontSize: 56)),
                    SizedBox(height: 12),
                    Text('Nothing cooked yet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text('Finish a recipe in Cooking Mode and it will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                final recipe = RecipeCatalog.byId(e.recipeId);
                if (recipe == null) return const SizedBox.shrink();
                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: FoodImage(
                      asset: recipe.imageAsset,
                      emoji: recipe.emoji,
                      width: 48,
                      height: 48,
                      radius: 12,
                      emojiSize: 24,
                    ),
                    title: Text(recipe.name),
                    subtitle: Text(formatDateTime(e.cookedAt)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => RecipeDetailsScreen(recipeId: recipe.id))),
                  ),
                );
              },
            ),
    );
  }
}
