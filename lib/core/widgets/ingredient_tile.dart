import 'package:flutter/material.dart';

import '../../features/ingredients/models/ingredient.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'food_image.dart';

/// Ingredient card with an orange border and checkmark when selected.
/// Used by Home and Select Ingredients screens.
class IngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final bool selected;
  final VoidCallback onTap;
  final double emojiSize;

  const IngredientTile({
    super.key,
    required this.ingredient,
    required this.selected,
    required this.onTap,
    this.emojiSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final imageSize = emojiSize * 1.3;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.orange
                : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: AppTheme.softShadow,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FoodImage(
                      url: ingredient.imageUrl,
                      asset: ingredient.imageAsset,
                      emoji: ingredient.emoji,
                      width: imageSize,
                      height: imageSize,
                      radius: 12,
                      emojiSize: emojiSize,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                    ),
                    child: Text(
                      ingredient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF302820),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Positioned(
                top: 0,
                right: 2,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: AppColors.orange,
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

