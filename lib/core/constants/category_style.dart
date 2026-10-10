import 'package:flutter/material.dart';

import '../../features/recipes/models/recipe.dart';

/// Look of the "Popular Categories" tiles.
class CategoryStyle {
  final Color color;
  final String emoji;
  final String subtitle;
  const CategoryStyle(this.color, this.emoji, this.subtitle);

  static CategoryStyle of(MealCategory c) => switch (c) {
        MealCategory.breakfast =>
          const CategoryStyle(Color(0xFFF59A3C), '🥞', 'Start your day right'),
        MealCategory.lunch =>
          const CategoryStyle(Color(0xFF5BAA5B), '🥗', 'Fresh & healthy'),
        MealCategory.dinner =>
          const CategoryStyle(Color(0xFF5B8DEF), '🍝', 'Comfort in every bite'),
        MealCategory.snacks =>
          const CategoryStyle(Color(0xFFEF6B3C), '🍟', 'Quick & tasty'),
      };
}
