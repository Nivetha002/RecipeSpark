import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/category_style.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ingredient_tile.dart';
import '../../../core/widgets/section_header.dart';
import '../../ingredients/data/ingredient_catalog.dart';
import '../../ingredients/screens/select_ingredients_screen.dart';
import '../../ingredients/state/ingredient_selection_provider.dart';
import '../../navigation/navigation_controller.dart';
import '../../profile/screens/profile_screen.dart';
import '../../recipes/data/recipe_catalog.dart';
import '../../recipes/models/recipe.dart';
import '../../recipes/screens/recipe_details_screen.dart';
import '../../recipes/screens/recipe_list_screen.dart';
import '../../recipes/services/recipe_matching_service.dart';
import '../widgets/featured_recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();

  static const _featuredIds = [
    'creamy_tomato_pasta',
    'garden_salad',
    'grilled_chicken_bowl',
    'fluffy_pancakes',
    'vegetable_stir_fry',
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  void _showNotifications() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text("You're all caught up. No new notifications."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<IngredientSelectionProvider>();
    final service = context.read<RecipeMatchingService>();
    final nav = context.read<NavigationController>();
    final featured = [
      for (final id in _featuredIds)
        if (RecipeCatalog.byId(id) != null) RecipeCatalog.byId(id)!,
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Header(
            onBell: _showNotifications,
            onAvatar: () => _push(const ProfileScreen()),
          ),
          const SizedBox(height: 16),
          _HeroBanner(onExplore: () => nav.openExplore()),
          const SizedBox(height: 16),
          TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: (v) => nav.openExplore(query: v),
            decoration: const InputDecoration(
              hintText: 'What would you like to cook?',
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
            ),
          ),
          SectionHeader(
            title: 'Quick Ingredients',
            onViewAll: () => _push(const SelectIngredientsScreen()),
          ),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
            children: [
              for (final ing in IngredientCatalog.quick)
                IngredientTile(
                  ingredient: ing,
                  selected: selection.isSelected(ing.id),
                  emojiSize: 44,
                  onTap: () => selection.toggle(ing.id),
                ),
            ],
          ),
          if (!selection.isEmpty) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _push(const SelectIngredientsScreen()),
              child: Text('Review ${selection.count} selected & find recipes'),
            ),
          ],
          const SectionHeader(title: 'Popular Categories'),
          Row(
            children: [
              for (final c in MealCategory.values)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: c == MealCategory.values.last ? 0 : 8),
                    child: _CategoryTile(
                      category: c,
                      onTap: () => _push(RecipeListScreen(
                        title: c.label,
                        recipes: RecipeCatalog.byCategory(c),
                      )),
                    ),
                  ),
                ),
            ],
          ),
          SectionHeader(
            title: 'Featured Recipes',
            onViewAll: () => _push(RecipeListScreen(
              title: 'Featured Recipes',
              recipes: featured,
            )),
          ),
          SizedBox(
            height: 212,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: featured.length,
              separatorBuilder: (_, i) => const SizedBox(width: 12),
              itemBuilder: (context, i) => FeaturedRecipeCard(
                match: service.evaluate(featured[i], selection.selected),
                showMatch: !selection.isEmpty,
                onTap: () =>
                    _push(RecipeDetailsScreen(recipeId: featured[i].id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBell;
  final VoidCallback onAvatar;
  const _Header({required this.onBell, required this.onAvatar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.local_fire_department,
            color: AppColors.orange, size: 34),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                const TextSpan(children: [
                  TextSpan(text: 'Recipe'),
                  TextSpan(
                      text: 'Spark', style: TextStyle(color: AppColors.orange)),
                ]),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('Good Food • Happy You',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: onBell,
          icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
        ),
        GestureDetector(
          onTap: onAvatar,
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.orangeSoft,
            child: Icon(Icons.person, color: AppColors.orange),
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onExplore;
  const _HeroBanner({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(18, 18, 8, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF3A1F10), Color(0xFF7A3B14)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Turn Simple Ingredients into Amazing Meals',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.25,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Discover recipes, save favourites and cook with confidence.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: onExplore,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Explore Recipes', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Text('🍝', style: TextStyle(fontSize: 72)),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final MealCategory category;
  final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.of(category);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: style.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
            const SizedBox(height: 2),
            Text(style.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 9)),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(style.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ],
        ),
      ),
    );
  }
}
