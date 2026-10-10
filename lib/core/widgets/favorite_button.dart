import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/saved/state/favorites_provider.dart';
import '../theme/app_colors.dart';

/// Heart toggle. Reads the shared FavoritesProvider, so every screen that
/// shows it stays in sync.
class FavoriteButton extends StatelessWidget {
  final String recipeId;
  const FavoriteButton({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final isFav =
        context.select<FavoritesProvider, bool>((p) => p.isFavorite(recipeId));
    return IconButton(
      tooltip: isFav ? 'Remove from saved' : 'Save recipe',
      onPressed: () => context.read<FavoritesProvider>().toggle(recipeId),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(6),
        minimumSize: const Size(34, 34),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        size: 20,
        color: isFav ? AppColors.orange : AppColors.textMuted,
      ),
    );
  }
}
