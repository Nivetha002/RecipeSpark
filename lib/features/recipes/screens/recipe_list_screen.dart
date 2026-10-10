import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../ingredients/state/ingredient_selection_provider.dart';
import '../models/recipe.dart';
import '../services/recipe_matching_service.dart';
import '../widgets/recipe_result_card.dart';
import 'recipe_details_screen.dart';

/// Reusable ranked recipe list.
///  * [onlyMatching] true  -> "Find Recipes" results (needs >=1 shared
///    required ingredient; shows an empty state otherwise).
///  * [onlyMatching] false -> every recipe in [recipes] (category / featured).
class RecipeListScreen extends StatelessWidget {
  final String title;
  final List<Recipe> recipes;
  final bool onlyMatching;

  const RecipeListScreen({
    super.key,
    required this.title,
    required this.recipes,
    this.onlyMatching = false,
  });

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<IngredientSelectionProvider>();
    final service = context.read<RecipeMatchingService>();
    final results = service.rank(recipes, selection.selected,
        includeAll: !onlyMatching);
    final showMatch = !selection.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(
                          onlyMatching
                              ? '${results.length} recipes for your ${selection.count} ingredients'
                              : '${results.length} recipes',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? _EmptyState(onlyMatching: onlyMatching)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: results.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => RecipeResultCard(
                        match: results[i],
                        showMatch: showMatch,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                RecipeDetailsScreen(recipeId: results[i].recipe.id),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool onlyMatching;
  const _EmptyState({required this.onlyMatching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              onlyMatching ? 'No recipes match yet' : 'No recipes here yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adding more ingredients, like pasta, egg or tomato, to see what you can cook.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Change ingredients'),
            ),
          ],
        ),
      ),
    );
  }
}
