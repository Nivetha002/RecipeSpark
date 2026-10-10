import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../ingredients/state/ingredient_selection_provider.dart';
import '../navigation/navigation_controller.dart';
import '../recipes/data/recipe_catalog.dart';
import '../recipes/models/recipe.dart';
import '../recipes/screens/recipe_details_screen.dart';
import '../recipes/services/recipe_matching_service.dart';
import '../recipes/services/recipe_search_service.dart';
import '../recipes/widgets/recipe_result_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _controller = TextEditingController();
  final _search = RecipeSearchService();
  String _query = '';
  MealCategory? _category;
  ExploreFilter? _filter;
  int _handledTick = 0;

  static const _filterStyle = {
    ExploreFilter.vegetarian: ('🥬', Color(0xFFE3F5EA)),
    ExploreFilter.highProtein: ('💪', Color(0xFFFFE8D5)),
    ExploreFilter.quickEasy: ('⚡', Color(0xFFFFF1CC)),
    ExploreFilter.healthy: ('❤️', Color(0xFFFDE4E4)),
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearAll() => setState(() {
        _controller.clear();
        _query = '';
        _category = null;
        _filter = null;
      });

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();
    if (nav.exploreTick != _handledTick) {
      _handledTick = nav.exploreTick;
      _controller.text = nav.exploreQuery;
      _query = nav.exploreQuery;
    }
    final selection = context.watch<IngredientSelectionProvider>();
    final matcher = context.read<RecipeMatchingService>();

    final results = _search.search(RecipeCatalog.all, _query,
        category: _category, filter: _filter);
    var matches = [for (final r in results) matcher.evaluate(r, selection.selected)];
    final isFiltering = _query.trim().isNotEmpty || _category != null || _filter != null;
    if (!selection.isEmpty && _query.trim().isEmpty) {
      matches.sort((a, b) {
        final byPct = b.percent.compareTo(a.percent);
        return byPct != 0 ? byPct : RecipeSearchService.popularity(a.recipe, b.recipe);
      });
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('Explore', style: Theme.of(context).textTheme.headlineSmall),
          Text('Discover new recipes',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Try "quick healthy dinner" or "egg"',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _controller.clear();
                        _query = '';
                      }),
                    ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 10),
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
          Text('Recipe Categories',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: [
              for (final f in ExploreFilter.values)
                _CategoryCard(
                  emoji: _filterStyle[f]!.$1,
                  color: _filterStyle[f]!.$2,
                  label: f.label,
                  count: RecipeCatalog.all
                      .where((r) => RecipeSearchService.matchesFilter(r, f))
                      .length,
                  selected: _filter == f,
                  onTap: () =>
                      setState(() => _filter = _filter == f ? null : f),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(isFiltering ? 'Results (${matches.length})' : 'Popular Recipes',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          if (matches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  const Text('No recipes found',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Try a different word or clear the filters.',
                      style: TextStyle(color: AppColors.textMuted)),
                  TextButton(onPressed: _clearAll, child: const Text('Clear filters')),
                ],
              ),
            )
          else
            for (final m in matches)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RecipeResultCard(
                  match: m,
                  showMatch: !selection.isEmpty,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => RecipeDetailsScreen(recipeId: m.recipe.id))),
                ),
              ),
        ],
      ),
    );
  }
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

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final Color color;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.emoji,
    required this.color,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? AppColors.orange : Colors.transparent, width: 2),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(12)),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('$count recipe${count == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
