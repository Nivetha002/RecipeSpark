import '../../../core/constants/image_urls.dart';

enum IngredientGroup {
  vegetables('Vegetables'),
  fruits('Fruits'),
  proteins('Proteins'),
  others('Others');

  final String label;
  const IngredientGroup(this.label);
}

/// Case/whitespace-insensitive key used everywhere ingredients are compared.
String normalizeIngredientName(String raw) =>
    raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

class Ingredient {
  /// Normalized name, e.g. "tomato". Used as the unique id.
  final String id;
  final String name;
  final String emoji;
  final IngredientGroup group;

  /// Pantry staples (salt, oil...) are assumed available: they are not shown
  /// in the picker and never count against the match percentage.
  final bool isStaple;

  const Ingredient({
    required this.id,
    required this.name,
    required this.emoji,
    required this.group,
    this.isStaple = false,
  });

  String? get imageUrl => kIngredientImages[id];

  /// Bundled photo. Missing file -> emoji fallback.
  String get imageAsset => 'assets/images/ingredients/$id.png';
}
