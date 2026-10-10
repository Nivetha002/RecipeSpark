import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/ingredients/state/ingredient_selection_provider.dart';
import 'features/navigation/main_shell.dart';
import 'features/navigation/navigation_controller.dart';
import 'features/profile/state/cooking_history_provider.dart';
import 'features/profile/state/profile_provider.dart';
import 'features/recipes/services/recipe_matching_service.dart';
import 'features/saved/state/favorites_provider.dart';
import 'features/shopping/state/shopping_list_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(RecipeSparkApp(prefs: prefs));
}

class RecipeSparkApp extends StatelessWidget {
  final SharedPreferences prefs;
  const RecipeSparkApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IngredientSelectionProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => CookingHistoryProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(prefs)),
        Provider(create: (_) => RecipeMatchingService()),
      ],
      child: MaterialApp(
        title: 'RecipeSpark',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MainShell(),
      ),
    );
  }
}
