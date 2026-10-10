import '../ingredients/data/ingredient_catalog.dart';
import '../ingredients/data/ingredient_labels.dart';
import '../recipes/data/recipe_catalog.dart';
import '../recipes/models/recipe.dart';
import '../recipes/services/recipe_matching_service.dart';
import '../recipes/services/recipe_search_service.dart';
import 'assistant_service.dart';

/// Offline demo assistant: keyword rules + the real recipe catalog.
/// It is NOT an AI model and the UI says so.
class LocalCookingAssistant implements CookingAssistantService {
  final RecipeMatchingService _matcher;
  final List<Recipe> _recipes;
  final Duration delay;

  LocalCookingAssistant({
    RecipeMatchingService? matcher,
    List<Recipe>? recipes,
    this.delay = const Duration(milliseconds: 450),
  })  : _matcher = matcher ?? RecipeMatchingService(),
        _recipes = recipes ?? RecipeCatalog.all;

  @override
  bool get isDemo => true;

  static const _substitutions = {
    'butter':
        'Yes. Use about ¾ tablespoon of oil for every tablespoon of butter. The result will be a little less rich.',
    'cream':
        'Milk plus a little butter works in most sauces: about ¾ cup milk and 1½ tbsp butter per cup of cream. It will be slightly thinner.',
    'egg':
        'In baking, ¼ cup yogurt or half a mashed banana can replace one egg. In savoury dishes the result varies by recipe.',
    'coriander':
        'Depending on the recipe, you can omit it or use fresh parsley or a little mint.',
    'lemon':
        'Use about half the amount of vinegar, or lime juice if you have it.',
    'milk':
        'Thinned yogurt, or water with a little butter, works in most recipes.',
  };

  @override
  Future<AssistantReply> ask(String question,
      {Set<String> pantry = const {}}) async {
    await Future<void>.delayed(delay);
    final q = question.toLowerCase().trim();
    if (q.isEmpty) throw const AssistantException('Please type a question.');
    return AssistantReply(_answer(q, pantry));
  }

  String _answer(String q, Set<String> pantry) {
    // 1. Substitutions
    if (RegExp(r"replace|substitut|swap|instead|without|don'?t have|out of|alternative")
        .hasMatch(q)) {
      for (final e in _substitutions.entries) {
        if (RegExp('\\b${e.key}\\b').hasMatch(q)) return e.value;
      }
    }

    // 2. Cooking help
    if (q.contains('spic') && RegExp(r'too|reduce|less|tone|fix|hot').hasMatch(q)) {
      return 'To tone down the heat: stir in yogurt or cream, add a pinch of sugar or a squeeze of lemon, or add more of the base ingredients (like potato or rice) to dilute it.';
    }
    if (q.contains('pasta') && RegExp(r'cream').hasMatch(q)) {
      return 'For a creamier pasta: keep a cup of the pasta water, add it a little at a time with cream, milk or grated cheese, and toss everything together over low heat until glossy.';
    }

    // 3. Recipe ideas
    final mentioned = <String>[
      for (final ing in IngredientCatalog.pickable)
        if (RegExp('\\b${ing.id}(s|es)?\\b').hasMatch(q)) ing.id,
    ];
    final asksWhat =
        RegExp(r'what (can|should) i (cook|make)').hasMatch(q);

    MealCategory? cat;
    for (final c in MealCategory.values) {
      final key = c == MealCategory.snacks ? 'snack' : c.name;
      if (q.contains(key)) cat = c;
    }
    final quick = RegExp(r'\b(quick|fast|easy)\b').hasMatch(q);
    final healthy = q.contains('healthy');
    final veg = q.contains('vegetarian');
    final protein = q.contains('protein');

    final pool = _recipes.where((r) {
      if (cat != null && r.category != cat) return false;
      if (quick && r.totalMinutes > 30) return false;
      if (healthy && !r.tags.contains(DietTag.healthy)) return false;
      if (veg && !r.tags.contains(DietTag.vegetarian)) return false;
      if (protein && !r.tags.contains(DietTag.highProtein)) return false;
      return true;
    }).toList();

    if (mentioned.isNotEmpty || asksWhat) {
      final have = mentioned.isNotEmpty ? mentioned.toSet() : pantry;
      if (have.isEmpty) {
        return 'Tell me which ingredients you have (for example "tomato, egg and onion") or select them on the Home screen, and I will suggest recipes.';
      }
      final ranked = _matcher.rank(pool, have).take(3).toList();
      if (ranked.isEmpty) {
        return 'I could not find a recipe using ${ingredientNames(have)} in the catalog yet. Try adding another ingredient.';
      }
      final lines = [
        for (final m in ranked)
          '• ${m.recipe.name}: ${m.percentRounded}% match'
              '${m.missingRequired.isEmpty ? '' : ' (missing ${ingredientNames(m.missingRequired)})'}',
      ];
      return 'With ${ingredientNames(have)} you could make:\n${lines.join('\n')}';
    }

    if (cat != null ||
        quick ||
        healthy ||
        veg ||
        protein ||
        RegExp(r'recipe|suggest|idea|recommend').hasMatch(q)) {
      if (pool.isEmpty) return 'I do not have a recipe for that yet.';
      pool.sort(quick
          ? (a, b) => a.totalMinutes.compareTo(b.totalMinutes)
          : RecipeSearchService.popularity);
      final lines = [
        for (final r in pool.take(3))
          '• ${r.name}: ${r.totalMinutes} min, ${r.difficulty.label}',
      ];
      return 'Here are some ideas:\n${lines.join('\n')}';
    }

    return 'I am running in offline demo mode, so I can only help with recipe ideas from your ingredients, quick meal suggestions and common substitutions. Try one of the suggested questions!';
  }
}
