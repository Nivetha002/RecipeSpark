import '../../../core/constants/image_urls.dart';

enum MealCategory {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snacks('Snacks');

  final String label;
  const MealCategory(this.label);
}

enum Difficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  final String label;
  const Difficulty(this.label);
}

/// Extra tags used by the Explore categories. "Quick & Easy" is derived.
enum DietTag {
  vegetarian('Vegetarian'),
  highProtein('High Protein'),
  healthy('Healthy');

  final String label;
  const DietTag(this.label);
}

class RecipeIngredient {
  final String ingredientId;

  /// Quantity for [Recipe.baseServings]. Null means "to taste".
  final double? quantity;
  final String unit;
  final bool isOptional;

  const RecipeIngredient(
    this.ingredientId, {
    this.quantity,
    this.unit = '',
    this.isOptional = false,
  });
}

class CookingStep {
  final String title;
  final String description;
  final String? tip;

  const CookingStep(this.title, this.description, {this.tip});
}

class Recipe {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final MealCategory category;
  final Difficulty difficulty;
  final int prepMinutes;
  final int cookMinutes;
  final int baseServings;
  final double rating;
  final int reviewCount;
  final Set<DietTag> tags;
  final List<RecipeIngredient> ingredients;
  final List<CookingStep> steps;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.difficulty,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.baseServings,
    required this.rating,
    required this.reviewCount,
    required this.ingredients,
    required this.steps,
    this.tags = const {},
  });

  String? get imageUrl => kRecipeImages[id];

  /// Bundled photo. Missing file -> emoji fallback.
  String get imageAsset => 'assets/images/recipes/$id.jpg';

  int get totalMinutes => prepMinutes + cookMinutes;

  bool get isQuickAndEasy =>
      totalMinutes <= 30 && difficulty == Difficulty.easy;

  List<RecipeIngredient> get requiredIngredients =>
      ingredients.where((i) => !i.isOptional).toList();

  List<RecipeIngredient> get optionalIngredients =>
      ingredients.where((i) => i.isOptional).toList();
}
