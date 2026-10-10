import 'ingredient_catalog.dart';

/// "pasta, tomato" -> "Pasta, Tomato"
String ingredientNames(Iterable<String> ids) =>
    ids.map((id) => IngredientCatalog.byId(id)?.name ?? id).join(', ');
