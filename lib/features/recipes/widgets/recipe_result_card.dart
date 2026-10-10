import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/favorite_button.dart';
import '../../../core/widgets/food_image.dart';
import '../../../core/widgets/match_badge.dart';
import '../../ingredients/data/ingredient_labels.dart';
import '../services/recipe_matching_service.dart';

/// Result row: photo, rating/time, prominent match %, have / missing lists.
class RecipeResultCard extends StatelessWidget {
  final MatchResult match;

  /// False when the user has no ingredients selected (a 0% badge would be
  /// misleading).
  final bool showMatch;
  final VoidCallback onTap;

  const RecipeResultCard({
    super.key,
    required this.match,
    required this.showMatch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = match.recipe;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FoodImage(
                  url: r.imageUrl,
                  asset: r.imageAsset,
                  emoji: r.emoji,
                  width: 96,
                  height: 96,
                  radius: 16,
                  emojiSize: 42,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(r.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                          FavoriteButton(recipeId: r.id),
                        ],
                      ),
                      Text(
                        '★ ${r.rating}  ·  ${r.totalMinutes} min  ·  ${r.difficulty.label}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (showMatch) ...[
                        const SizedBox(height: 6),
                        MatchBadge(percent: match.percentRounded),
                        if (match.matchedRequired.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            '✓ ${ingredientNames(match.matchedRequired)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.matchGreen),
                          ),
                        ],
                        if (match.missingRequired.isNotEmpty)
                          Text(
                            '○ Missing: ${ingredientNames(match.missingRequired)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
