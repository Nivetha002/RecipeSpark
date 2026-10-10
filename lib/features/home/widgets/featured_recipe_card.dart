import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/favorite_button.dart';
import '../../../core/widgets/food_image.dart';
import '../../../core/widgets/match_badge.dart';
import '../../recipes/services/recipe_matching_service.dart';

class FeaturedRecipeCard extends StatelessWidget {
  final MatchResult match;
  final bool showMatch;
  final VoidCallback onTap;

  const FeaturedRecipeCard({
    super.key,
    required this.match,
    required this.showMatch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = match.recipe;
    return SizedBox(
      width: 190,
      child: DecoratedBox(
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
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      FoodImage(
                        url: r.imageUrl,
                        asset: r.imageAsset,
                        emoji: r.emoji,
                        width: double.infinity,
                        height: 104,
                        radius: 14,
                        emojiSize: 48,
                      ),
                      Positioned(
                          top: 4, right: 4, child: FavoriteButton(recipeId: r.id)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${r.totalMinutes} mins · ${r.difficulty.label}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  if (showMatch)
                    MatchBadge(percent: match.percentRounded)
                  else
                    Text('★ ${r.rating}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
