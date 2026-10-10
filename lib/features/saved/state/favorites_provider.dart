import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../recipes/data/recipe_catalog.dart';
import '../../recipes/models/recipe.dart';

/// Favourite recipe ids, saved on the device with shared_preferences.
/// One instance is shared by Home, Recipe Details and Saved.
class FavoritesProvider extends ChangeNotifier {
  static const storageKey = 'favorite_recipe_ids';

  final SharedPreferences _prefs;
  final List<String> _ids;

  FavoritesProvider(this._prefs)
      : _ids = List<String>.from(_prefs.getStringList(storageKey) ?? const []);

  bool isFavorite(String recipeId) => _ids.contains(recipeId);

  /// Saved recipes, newest first. Ids no longer in the catalog are skipped.
  List<Recipe> get recipes => [
        for (final id in _ids)
          if (RecipeCatalog.byId(id) != null) RecipeCatalog.byId(id)!,
      ];

  int get count => recipes.length;

  Future<void> toggle(String recipeId) async {
    if (!_ids.remove(recipeId)) _ids.insert(0, recipeId);
    notifyListeners();
    try {
      await _prefs.setStringList(storageKey, _ids);
    } catch (e) {
      debugPrint('Could not save favourites: $e');
    }
  }
}
