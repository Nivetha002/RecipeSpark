import '../../ingredients/data/ingredient_catalog.dart';
import '../models/recipe.dart';

enum ExploreFilter {
  vegetarian('Vegetarian'),
  highProtein('High Protein'),
  quickEasy('Quick & Easy'),
  healthy('Healthy');

  final String label;
  const ExploreFilter(this.label);
}

/// Local, deterministic recipe search. Understands plain words
/// ("chicken") and simple phrases ("quick healthy breakfast",
/// "I have potato and egg, what can I make for dinner?").
class RecipeSearchService {
  static const _stop = {
    'i', 'a', 'an', 'the', 'and', 'or', 'with', 'for', 'me', 'my', 'have',
    'want', 'give', 'something', 'what', 'can', 'make', 'cook', 'to', 'of',
    'some', 'that', 'takes', 'than', 'less', 'minutes', 'in', 'is', 'recipe',
    'recipes', 'show', 'find', 'need', 'got', 'please', 'any', 'good',
  };

  static bool matchesFilter(Recipe r, ExploreFilter f) => switch (f) {
        ExploreFilter.vegetarian => r.tags.contains(DietTag.vegetarian),
        ExploreFilter.highProtein => r.tags.contains(DietTag.highProtein),
        ExploreFilter.healthy => r.tags.contains(DietTag.healthy),
        ExploreFilter.quickEasy => r.isQuickAndEasy,
      };

  static int popularity(Recipe a, Recipe b) {
    final byRating = b.rating.compareTo(a.rating);
    if (byRating != 0) return byRating;
    final byReviews = b.reviewCount.compareTo(a.reviewCount);
    if (byReviews != 0) return byReviews;
    return a.name.compareTo(b.name);
  }

  List<Recipe> search(
    Iterable<Recipe> recipes,
    String query, {
    MealCategory? category,
    ExploreFilter? filter,
  }) {
    var cat = category;
    final filters = <ExploreFilter>{?filter};
    final words = query
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.length > 1 && !_stop.contains(w))
        .toList();

    final content = <String>[];
    for (final w in words) {
      if (w == 'breakfast') {
        cat ??= MealCategory.breakfast;
      } else if (w == 'lunch') {
        cat ??= MealCategory.lunch;
      } else if (w == 'dinner') {
        cat ??= MealCategory.dinner;
      } else if (w == 'snack' || w == 'snacks') {
        cat ??= MealCategory.snacks;
      } else if (w == 'quick' || w == 'fast' || w == 'easy') {
        filters.add(ExploreFilter.quickEasy);
      } else if (w == 'healthy') {
        filters.add(ExploreFilter.healthy);
      } else if (w == 'vegetarian' || w == 'veg') {
        filters.add(ExploreFilter.vegetarian);
      } else if (w == 'protein') {
        filters.add(ExploreFilter.highProtein);
      } else {
        content.add(w);
      }
    }

    final base = recipes.where((r) {
      if (cat != null && r.category != cat) return false;
      return filters.every((f) => matchesFilter(r, f));
    });

    final scored = <MapEntry<Recipe, int>>[];
    for (final r in base) {
      if (content.isEmpty) {
        scored.add(MapEntry(r, 0));
        continue;
      }
      final hay = _haystack(r);
      var score = 0;
      for (final w in content) {
        if (_variants(w).any(hay.contains)) score++;
      }
      if (score > 0) scored.add(MapEntry(r, score));
    }

    scored.sort((a, b) {
      final byScore = b.value.compareTo(a.value);
      return byScore != 0 ? byScore : popularity(a.key, b.key);
    });
    return scored.map((e) => e.key).toList();
  }

  String _haystack(Recipe r) {
    final names = r.ingredients
        .map((i) => IngredientCatalog.byId(i.ingredientId)?.name ?? i.ingredientId)
        .join(' ');
    return '${r.name} ${r.description} ${r.category.label} $names'.toLowerCase();
  }

  List<String> _variants(String w) => [
        w,
        if (w.endsWith('es')) w.substring(0, w.length - 2),
        if (w.endsWith('s')) w.substring(0, w.length - 1),
      ];
}
