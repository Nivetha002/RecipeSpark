import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../ingredients/state/ingredient_selection_provider.dart';
import '../navigation/navigation_controller.dart';
import '../recipes/models/recipe.dart';
import '../recipes/screens/recipe_details_screen.dart';
import '../recipes/services/recipe_matching_service.dart';
import '../recipes/widgets/recipe_result_card.dart';
import 'state/favorites_provider.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  MealCategory? _category;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final selection = context.watch<IngredientSelectionProvider>();
    final matcher = context.read<RecipeMatchingService>();

    final all = favorites.recipes;
    final shown =
        all.where((r) => _category == null || r.category == _category).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saved Recipes',
                    style: Theme.of(context).textTheme.headlineSmall),
                Text('Your favourite recipes',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _Pill(
                    label: 'All',
                    selected: _category == null,
                    onTap: () => setState(() => _category = null)),
                for (final c in MealCategory.values)
                  _Pill(
                      label: c.label,
                      selected: _category == c,
                      onTap: () => setState(() => _category = c)),
              ],
            ),
          ),
          Expanded(
            child: shown.isEmpty
                ? _Empty(
                    hasAny: all.isNotEmpty,
                    categoryLabel: _category?.label,
                    onExplore: () => context.read<NavigationController>().openExplore(),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: shown.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => RecipeResultCard(
                      match: matcher.evaluate(shown[i], selection.selected),
                      showMatch: !selection.isEmpty,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              RecipeDetailsScreen(recipeId: shown[i].id))),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final bool hasAny;
  final String? categoryLabel;
  final VoidCallback onExplore;
  const _Empty(
      {required this.hasAny, required this.categoryLabel, required this.onExplore});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🤍', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                hasAny
                    ? 'No saved ${categoryLabel?.toLowerCase()} recipes'
                    : 'No saved recipes yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Tap the heart on any recipe to save it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
                onPressed: onExplore,
                child: const Text('Explore recipes'),
              ),
            ],
          ),
        ),
      );
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Pill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.orange : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: selected ? AppColors.orange : AppColors.border),
            ),
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textDark)),
          ),
        ),
      );
}
