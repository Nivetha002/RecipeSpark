import '../../ingredients/data/ingredient_catalog.dart';
import '../../ingredients/models/ingredient.dart';
import '../models/recipe.dart';

/// Result of comparing one recipe against the user's ingredients.
class MatchResult {
  final Recipe recipe;

  /// Required (non-staple) ingredient ids the user has.
  final List<String> matchedRequired;

  /// Required (non-staple) ingredient ids the user is missing.
  final List<String> missingRequired;

  /// Optional ingredient ids the user has (informational only).
  final List<String> matchedOptional;

  const MatchResult({
    required this.recipe,
    required this.matchedRequired,
    required this.missingRequired,
    required this.matchedOptional,
  });

  int get requiredCount => matchedRequired.length + missingRequired.length;

  /// matched required / total required * 100. Returns 0 when the recipe has
  /// no countable required ingredients (avoids divide-by-zero).
  double get percent =>
      requiredCount == 0 ? 0 : matchedRequired.length / requiredCount * 100;

  /// 7 of 8 -> 87.5 -> 88.
  int get percentRounded => percent.round();

  bool get isComplete => requiredCount > 0 && missingRequired.isEmpty;
}

/// Deterministic matching. Rules:
///  * ids are normalized (case / whitespace).
///  * optional ingredients never count toward the percentage.
///  * pantry staples (salt, oil...) are assumed available and ignored.
///  * ranking: higher % first, then fewer missing, then higher rating,
///    then name.
class RecipeMatchingService {
  final bool Function(String id) _isStaple;

  RecipeMatchingService({bool Function(String id)? isStaple})
      : _isStaple = isStaple ?? IngredientCatalog.isStaple;

  MatchResult evaluate(Recipe recipe, Iterable<String> selected) {
    final have = selected.map(normalizeIngredientName).toSet();
    final matched = <String>[];
    final missing = <String>[];
    final optional = <String>[];

    for (final ing in recipe.ingredients) {
      final id = normalizeIngredientName(ing.ingredientId);
      if (ing.isOptional) {
        if (have.contains(id)) optional.add(id);
        continue;
      }
      if (_isStaple(id)) continue;
      (have.contains(id) ? matched : missing).add(id);
    }

    return MatchResult(
      recipe: recipe,
      matchedRequired: matched,
      missingRequired: missing,
      matchedOptional: optional,
    );
  }

  /// Ranked results. By default only recipes sharing at least one required
  /// ingredient with the selection are returned, so an empty selection gives
  /// an empty list. Pass [includeAll] to rank every recipe (e.g. for Home
  /// cards that still show a percentage).
  List<MatchResult> rank(
    Iterable<Recipe> recipes,
    Iterable<String> selected, {
    bool includeAll = false,
  }) {
    final list = recipes
        .map((r) => evaluate(r, selected))
        .where((m) => includeAll || m.matchedRequired.isNotEmpty)
        .toList();

    list.sort((a, b) {
      final byPercent = b.percent.compareTo(a.percent);
      if (byPercent != 0) return byPercent;
      final byMissing =
          a.missingRequired.length.compareTo(b.missingRequired.length);
      if (byMissing != 0) return byMissing;
      final byRating = b.recipe.rating.compareTo(a.recipe.rating);
      if (byRating != 0) return byRating;
      return a.recipe.name.compareTo(b.recipe.name);
    });
    return list;
  }
}
