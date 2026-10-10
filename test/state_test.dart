import 'package:flutter_test/flutter_test.dart';
import 'package:recime/features/ingredients/state/ingredient_selection_provider.dart';
import 'package:recime/features/saved/state/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('IngredientSelectionProvider', () {
    test('toggle adds then removes, ids are normalized', () {
      final p = IngredientSelectionProvider();
      p.toggle('  Tomato ');
      expect(p.isSelected('tomato'), isTrue);
      expect(p.count, 1);
      p.toggle('TOMATO');
      expect(p.isEmpty, isTrue);
    });

    test('addAll does not duplicate and clear empties', () {
      final p = IngredientSelectionProvider();
      p.addAll(['egg', 'Egg', 'onion']);
      expect(p.count, 2);
      p.clear();
      expect(p.count, 0);
    });

    test('notifies listeners on change', () {
      final p = IngredientSelectionProvider();
      var calls = 0;
      p.addListener(() => calls++);
      p.toggle('egg');
      expect(calls, 1);
    });
  });

  group('FavoritesProvider', () {
    test('toggle saves and removes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final f = FavoritesProvider(prefs);
      await f.toggle('garden_salad');
      expect(f.isFavorite('garden_salad'), isTrue);
      expect(f.count, 1);
      await f.toggle('garden_salad');
      expect(f.isFavorite('garden_salad'), isFalse);
    });

    test('favourites persist across instances', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await FavoritesProvider(prefs).toggle('creamy_tomato_pasta');
      final reloaded = FavoritesProvider(prefs);
      expect(reloaded.isFavorite('creamy_tomato_pasta'), isTrue);
    });

    test('unknown ids are ignored in the recipe list', () async {
      SharedPreferences.setMockInitialValues({
        FavoritesProvider.storageKey: ['does_not_exist', 'garden_salad'],
      });
      final prefs = await SharedPreferences.getInstance();
      expect(FavoritesProvider(prefs).recipes.map((r) => r.id), ['garden_salad']);
    });
  });
}
