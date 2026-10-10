import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/favorite_button.dart';
import '../../../core/widgets/food_image.dart';
import '../../../core/widgets/match_badge.dart';
import '../../ingredients/data/ingredient_catalog.dart';
import '../../ingredients/data/ingredient_labels.dart';
import '../../ingredients/state/ingredient_selection_provider.dart';
import '../../shopping/screens/shopping_list_screen.dart';
import '../../shopping/state/shopping_list_provider.dart';
import '../data/recipe_catalog.dart';
import '../models/recipe.dart';
import '../services/recipe_matching_service.dart';
import '../services/serving_scaler.dart';
import 'cooking_screen.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String recipeId;
  const RecipeDetailsScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  int? _servings;

  String _reviews(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  void _addMissing(List<String> ids) {
    final added = context.read<ShoppingListProvider>().addAll(ids);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(added == 0
            ? 'Already on your shopping list'
            : 'Added $added item${added == 1 ? '' : 's'} to your shopping list'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShoppingListScreen())),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final recipe = RecipeCatalog.byId(widget.recipeId);
    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Recipe not found.')),
      );
    }
    final servings = _servings ?? recipe.baseServings;
    final selection = context.watch<IngredientSelectionProvider>();
    final match = context
        .read<RecipeMatchingService>()
        .evaluate(recipe, selection.selected);
    final required = recipe.requiredIngredients;
    final optional = recipe.optionalIngredients;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Stack(
                  children: [
                    FoodImage(
                      url: recipe.imageUrl,
                      asset: recipe.imageAsset,
                      emoji: recipe.emoji,
                      height: 260,
                      width: double.infinity,
                      radius: 0,
                      emojiSize: 100,
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              tooltip: 'Back',
                              style: IconButton.styleFrom(
                                  backgroundColor: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            FavoriteButton(recipeId: recipe.id),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.name,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                              '★ ${recipe.rating} (${_reviews(recipe.reviewCount)} reviews)',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (!selection.isEmpty)
                            MatchBadge(percent: match.percentRounded),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(recipe.description,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _StatBox(
                              icon: Icons.timer_outlined,
                              value: '${recipe.prepMinutes} mins',
                              label: 'Prep time'),
                          const SizedBox(width: 8),
                          _StatBox(
                              icon: Icons.local_fire_department_outlined,
                              value: recipe.cookMinutes == 0
                                  ? 'No cooking'
                                  : '${recipe.cookMinutes} mins',
                              label: 'Cook time'),
                          const SizedBox(width: 8),
                          _StatBox(
                              icon: Icons.bar_chart,
                              value: recipe.difficulty.label,
                              label: 'Difficulty'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Ingredients',
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                          _ServingsStepper(
                            servings: servings,
                            onChanged: (v) => setState(() => _servings = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const _GroupLabel('Required'),
                      for (final ing in required)
                        _IngredientRow(
                          ing: ing,
                          base: recipe.baseServings,
                          servings: servings,
                          haveStatus: _have(ing, selection),
                        ),
                      if (optional.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const _GroupLabel('Optional'),
                        for (final ing in optional)
                          _IngredientRow(
                            ing: ing,
                            base: recipe.baseServings,
                            servings: servings,
                            haveStatus: _have(ing, selection),
                          ),
                      ],
                      const SizedBox(height: 20),
                      _MissingSection(
                        hasSelection: !selection.isEmpty,
                        missing: match.missingRequired,
                        onAdd: () => _addMissing(match.missingRequired),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.cream,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CookingScreen(recipeId: recipe.id))),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Cooking'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// null = not applicable (staple, or nothing selected).
  bool? _have(RecipeIngredient ing, IngredientSelectionProvider sel) {
    if (sel.isEmpty || IngredientCatalog.isStaple(ing.ingredientId)) return null;
    return sel.isSelected(ing.ingredientId);
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatBox({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.orange),
            const SizedBox(height: 4),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ServingsStepper extends StatelessWidget {
  final int servings;
  final ValueChanged<int> onChanged;
  const _ServingsStepper({required this.servings, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const Key('servings_minus'),
          tooltip: 'Fewer servings',
          visualDensity: VisualDensity.compact,
          onPressed: servings > 1 ? () => onChanged(servings - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.orange,
        ),
        Text('Serves $servings',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        IconButton(
          key: const Key('servings_plus'),
          tooltip: 'More servings',
          visualDensity: VisualDensity.compact,
          onPressed: servings < 12 ? () => onChanged(servings + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.orange,
        ),
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted)),
      );
}

class _IngredientRow extends StatelessWidget {
  final RecipeIngredient ing;
  final int base;
  final int servings;
  final bool? haveStatus;

  const _IngredientRow({
    required this.ing,
    required this.base,
    required this.servings,
    required this.haveStatus,
  });

  @override
  Widget build(BuildContext context) {
    final info = IngredientCatalog.byId(ing.ingredientId);
    final isStaple = info?.isStaple ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          FoodImage(
            asset: info?.imageAsset,
            emoji: info?.emoji ?? '🍽️',
            width: 38,
            height: 38,
            radius: 10,
            emojiSize: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(info?.name ?? ing.ingredientId,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (isStaple)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text('Pantry',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            )
          else if (haveStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                haveStatus! ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: haveStatus! ? AppColors.matchGreen : AppColors.textMuted,
              ),
            ),
          Text(
            ServingScaler.scaledText(ing.quantity, ing.unit, base, servings),
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MissingSection extends StatelessWidget {
  final bool hasSelection;
  final List<String> missing;
  final VoidCallback onAdd;
  const _MissingSection(
      {required this.hasSelection, required this.missing, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final String body;
    if (!hasSelection) {
      body = 'Select the ingredients you have on Home to see what you are missing.';
    } else if (missing.isEmpty) {
      body = 'You have everything you need. Happy cooking!';
    } else {
      body = ingredientNames(missing);
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orangeSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Missing ingredients',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(body),
          if (hasSelection && missing.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Add to shopping list'),
            ),
          ],
        ],
      ),
    );
  }
}
