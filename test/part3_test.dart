import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recime/features/assistant/local_cooking_assistant.dart';
import 'package:recime/features/ingredients/state/ingredient_selection_provider.dart';
import 'package:recime/features/profile/state/cooking_history_provider.dart';
import 'package:recime/features/recipes/data/recipe_catalog.dart';
import 'package:recime/features/recipes/models/recipe.dart';
import 'package:recime/features/recipes/screens/recipe_details_screen.dart';
import 'package:recime/features/recipes/services/recipe_matching_service.dart';
import 'package:recime/features/recipes/services/recipe_search_service.dart';
import 'package:recime/features/saved/state/favorites_provider.dart';
import 'package:recime/features/shopping/state/shopping_list_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('cooking streak', () {
    final today = DateTime(2026, 10, 10, 12);
    test('no history = 0', () {
      expect(CookingHistoryProvider.computeStreak([], today), 0);
    });
    test('today and yesterday = 2', () {
      expect(
          CookingHistoryProvider.computeStreak(
              [DateTime(2026, 10, 10, 8), DateTime(2026, 10, 9, 20)], today),
          2);
    });
    test('streak survives until you cook today (yesterday counts)', () {
      expect(
          CookingHistoryProvider.computeStreak([DateTime(2026, 10, 9)], today), 1);
    });
    test('a gap breaks the streak', () {
      expect(
          CookingHistoryProvider.computeStreak(
              [DateTime(2026, 10, 10), DateTime(2026, 10, 8)], today),
          1);
    });
    test('old history only = 0', () {
      expect(
          CookingHistoryProvider.computeStreak([DateTime(2026, 9, 1)], today), 0);
    });
  });

  group('providers', () {
    test('history records, persists and clears', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final h = CookingHistoryProvider(prefs, now: () => DateTime(2026, 10, 10));
      await h.record('garden_salad');
      expect(h.totalCooked, 1);
      expect(h.streak, 1);
      expect(CookingHistoryProvider(prefs).totalCooked, 1);
      await h.clear();
      expect(h.totalCooked, 0);
    });

    test('shopping list adds without duplicates and toggles', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final s = ShoppingListProvider(prefs);
      expect(s.addAll(['Garlic', 'cream', 'garlic']), 2);
      expect(s.addAll(['cream']), 0);
      s.toggle('garlic');
      expect(s.items.firstWhere((e) => e.ingredientId == 'garlic').checked, isTrue);
      s.clearChecked();
      expect(s.count, 1);
    });
  });

  group('search', () {
    final search = RecipeSearchService();
    test('plain ingredient word', () {
      final r = search.search(RecipeCatalog.all, 'banana');
      expect(r.map((e) => e.id), contains('banana_smoothie'));
    });
    test('plural forms match', () {
      final r = search.search(RecipeCatalog.all, 'tomatoes');
      expect(r, isNotEmpty);
    });
    test('natural language: quick healthy breakfast', () {
      final r = search.search(RecipeCatalog.all, 'give me a healthy breakfast');
      for (final x in r) {
        expect(x.category, MealCategory.breakfast);
        expect(x.tags, contains(DietTag.healthy));
      }
    });
    test('category filter and unknown words', () {
      expect(
          search
              .search(RecipeCatalog.all, '', category: MealCategory.snacks)
              .every((r) => r.category == MealCategory.snacks),
          isTrue);
      expect(search.search(RecipeCatalog.all, 'zzzz'), isEmpty);
    });
  });

  group('local assistant', () {
    final a = LocalCookingAssistant(delay: Duration.zero);
    test('substitution', () async {
      final r = await a.ask('Can I replace butter with oil?');
      expect(r.text, contains('¾'));
    });
    test('ingredient suggestions use the real catalog', () async {
      final r = await a.ask('What can I cook with tomatoes?');
      expect(r.text, contains('Creamy Tomato Pasta'));
    });
    test('unknown question is honest about demo mode', () async {
      final r = await a.ask('Who won the match?');
      expect(r.text.toLowerCase(), contains('demo'));
    });
    test('is flagged as demo', () => expect(a.isDemo, isTrue));
  });

  testWidgets('servings stepper rescales quantities', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IngredientSelectionProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider(prefs)),
        Provider(create: (_) => RecipeMatchingService()),
      ],
      child: const MaterialApp(
          home: RecipeDetailsScreen(recipeId: 'creamy_tomato_pasta')),
    ));

    expect(find.text('200 g'), findsOneWidget);
    await tester.tap(find.byKey(const Key('servings_plus')));
    await tester.pump();
    expect(find.text('Serves 3'), findsOneWidget);
    expect(find.text('300 g'), findsOneWidget);
  });
}
