import 'package:flutter_test/flutter_test.dart';
import 'package:recime/features/ingredients/data/ingredient_catalog.dart';
import 'package:recime/features/recipes/data/recipe_catalog.dart';
import 'package:recime/features/recipes/models/recipe.dart';
import 'package:recime/features/recipes/services/recipe_matching_service.dart';
import 'package:recime/features/recipes/services/serving_scaler.dart';

void main() {
  final service = RecipeMatchingService();
  final pasta = RecipeCatalog.byId('creamy_tomato_pasta')!;

  group('matching', () {
    test('full match is 100% with nothing missing', () {
      final m = service.evaluate(pasta, ['pasta', 'tomato', 'garlic', 'cream']);
      expect(m.percentRounded, 100);
      expect(m.missingRequired, isEmpty);
      expect(m.isComplete, isTrue);
    });

    test('partial match lists missing required ingredients', () {
      final m = service.evaluate(pasta, ['pasta', 'tomato']);
      expect(m.percent, 50);
      expect(m.missingRequired, containsAll(['garlic', 'cream']));
    });

    test('names are normalized for case and whitespace', () {
      final m = service.evaluate(pasta, ['  PASTA ', 'Tomato']);
      expect(m.matchedRequired, containsAll(['pasta', 'tomato']));
    });

    test('optional ingredients do not change the percentage', () {
      final without = service.evaluate(pasta, ['pasta']);
      final withOptional = service.evaluate(pasta, ['pasta', 'basil', 'cheese']);
      expect(withOptional.percent, without.percent);
      expect(withOptional.matchedOptional, containsAll(['basil', 'cheese']));
    });

    test('staples are not counted as required', () {
      final m = service.evaluate(pasta, ['pasta']);
      expect(m.requiredCount, 4); // pasta, tomato, garlic, cream
      expect(m.missingRequired, isNot(contains('olive oil')));
    });

    test('empty selection returns no results and does not crash', () {
      expect(service.rank(RecipeCatalog.all, []), isEmpty);
      expect(service.evaluate(pasta, []).percent, 0);
    });

    test('recipe with no required ingredients gives 0%, not an error', () {
      const empty = Recipe(
        id: 'x', name: 'x', description: '', emoji: '', 
        category: MealCategory.snacks, difficulty: Difficulty.easy,
        prepMinutes: 1, cookMinutes: 1, baseServings: 1,
        rating: 0, reviewCount: 0, ingredients: [], steps: [],
      );
      expect(service.evaluate(empty, ['egg']).percent, 0);
    });

    test('results are ranked by percentage, best first', () {
      final ranked = service.rank(RecipeCatalog.all, ['egg', 'onion', 'tomato']);
      expect(ranked, isNotEmpty);
      for (var i = 1; i < ranked.length; i++) {
        expect(ranked[i - 1].percent >= ranked[i].percent, isTrue);
      }
    });

    test('7 of 8 required rounds to 88%', () {
      final recipe = Recipe(
        id: 'eight', name: 'eight', description: '', emoji: '',
        category: MealCategory.dinner, difficulty: Difficulty.easy,
        prepMinutes: 1, cookMinutes: 1, baseServings: 1,
        rating: 0, reviewCount: 0, steps: const [],
        ingredients: [
          for (final id in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'])
            RecipeIngredient(id, quantity: 1),
        ],
      );
      final m = RecipeMatchingService(isStaple: (_) => false)
          .evaluate(recipe, ['a', 'b', 'c', 'd', 'e', 'f', 'g']);
      expect(m.percent, 87.5);
      expect(m.percentRounded, 88);
    });
  });

  group('serving scaler', () {
    test('doubles quantities when servings double', () {
      expect(ServingScaler.scaledText(200, 'g', 2, 4), '400 g');
      expect(ServingScaler.scaledText(3, 'medium', 2, 4), '6 medium');
    });

    test('formats fractions', () {
      expect(ServingScaler.scaledText(0.25, 'cup', 2, 2), '¼ cup');
      expect(ServingScaler.scaledText(0.5, 'cup', 2, 3), '¾ cup');
      expect(ServingScaler.scaledText(1, 'cup', 2, 3), '1½ cup');
    });

    test('to taste has no quantity', () {
      expect(ServingScaler.scaledText(null, '', 2, 6), 'To taste');
    });

    test('invalid servings do not crash', () {
      expect(ServingScaler.scale(10, 0, 4), 10);
    });
  });

  group('catalog consistency', () {
    test('recipe ids are unique', () {
      final ids = RecipeCatalog.all.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every recipe ingredient exists in the ingredient catalog', () {
      for (final r in RecipeCatalog.all) {
        for (final i in r.ingredients) {
          expect(IngredientCatalog.byId(i.ingredientId), isNotNull,
              reason: '${r.id} uses unknown ingredient ${i.ingredientId}');
        }
      }
    });

    test('every recipe has steps and servings', () {
      for (final r in RecipeCatalog.all) {
        expect(r.steps, isNotEmpty, reason: r.id);
        expect(r.baseServings, greaterThan(0), reason: r.id);
      }
    });

    test('parseList understands comma-separated input', () {
      final parsed = IngredientCatalog.parseList('Chicken, onion , tomato, nonsense');
      expect(parsed.map((e) => e.id), ['chicken', 'onion', 'tomato']);
    });
  });
}
