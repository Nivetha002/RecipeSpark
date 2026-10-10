import '../models/ingredient.dart';

/// Single source of truth for ingredients and their food photos.
class IngredientCatalog {
  IngredientCatalog._();

  static const _v = IngredientGroup.vegetables;
  static const _f = IngredientGroup.fruits;
  static const _p = IngredientGroup.proteins;
  static const _o = IngredientGroup.others;

  // Food photos from Unsplash Source images.
  // FoodImage automatically falls back to the emoji if loading fails.
  static const Map<String, String> _photos = {
    'tomato':
        'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=300&h=300&fit=crop',
    'onion':
        'https://images.unsplash.com/photo-1508747703725-719777637510?w=300&h=300&fit=crop',
    'potato':
        'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=300&h=300&fit=crop',
    'carrot':
        'https://images.unsplash.com/photo-1445282768818-728615cc910a?w=300&h=300&fit=crop',
    'spinach':
        'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=300&h=300&fit=crop',
    'capsicum':
        'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=300&h=300&fit=crop',
    'garlic':
        'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=300&h=300&fit=crop',
    'mushroom':
        'https://images.unsplash.com/photo-1504545102780-26774c1bb073?w=300&h=300&fit=crop',
    'broccoli':
        'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=300&h=300&fit=crop',
    'corn':
        'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=300&h=300&fit=crop',
    'zucchini':
        'https://images.unsplash.com/photo-1563252722-6434563a985d?w=300&h=300&fit=crop',
    'cucumber':
        'https://images.unsplash.com/photo-1604977042946-1eecc30f269e?w=300&h=300&fit=crop',
    'lettuce':
        'https://images.unsplash.com/photo-1556801712-76c8eb07bbc9?w=300&h=300&fit=crop',
    'banana':
        'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300&h=300&fit=crop',
    'lemon':
        'https://images.unsplash.com/photo-1513558161293-cdaf765edfd7?w=300&h=300&fit=crop',
    'apple':
        'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=300&h=300&fit=crop',
    'egg':
        'https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=300&h=300&fit=crop',
    'chicken':
        'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=300&h=300&fit=crop',
    'chickpeas':
        'https://images.unsplash.com/photo-1515543904379-3d757afe72e4?w=300&h=300&fit=crop',
    'pasta':
        'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=300&h=300&fit=crop',
    'rice':
        'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=300&h=300&fit=crop',
    'bread':
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300&h=300&fit=crop',
    'cheese':
        'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=300&h=300&fit=crop',
    'milk':
        'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=300&h=300&fit=crop',
    'butter':
        'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=300&h=300&fit=crop',
    'cream':
        'https://images.unsplash.com/photo-1634141510639-d691d86f47be?w=300&h=300&fit=crop',
    'flour':
        'https://images.unsplash.com/photo-1627485937980-221c88ac04f9?w=300&h=300&fit=crop',
    'quinoa':
        'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=300&h=300&fit=crop',
    'yogurt':
        'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=300&h=300&fit=crop',
    'basil':
        'https://images.unsplash.com/photo-1618375569909-3c8616cf7733?w=300&h=300&fit=crop',
  };

  static Ingredient _ingredient({
    required String id,
    required String name,
    required String emoji,
    required IngredientGroup group,
    bool isStaple = false,
  }) {
    return Ingredient(
      id: id,
      name: name,
      emoji: emoji,
      group: group,
      isStaple: isStaple,
    );
  }

  static final List<Ingredient> all = [
    // Vegetables
    _ingredient(id: 'tomato', name: 'Tomato', emoji: '🍅', group: _v),
    _ingredient(id: 'onion', name: 'Onion', emoji: '🧅', group: _v),
    _ingredient(id: 'potato', name: 'Potato', emoji: '🥔', group: _v),
    _ingredient(id: 'carrot', name: 'Carrot', emoji: '🥕', group: _v),
    _ingredient(id: 'spinach', name: 'Spinach', emoji: '🥬', group: _v),
    _ingredient(id: 'capsicum', name: 'Capsicum', emoji: '🫑', group: _v),
    _ingredient(id: 'garlic', name: 'Garlic', emoji: '🧄', group: _v),
    _ingredient(id: 'mushroom', name: 'Mushroom', emoji: '🍄', group: _v),
    _ingredient(id: 'broccoli', name: 'Broccoli', emoji: '🥦', group: _v),
    _ingredient(id: 'corn', name: 'Corn', emoji: '🌽', group: _v),
    _ingredient(id: 'zucchini', name: 'Zucchini', emoji: '🥒', group: _v),
    _ingredient(id: 'cucumber', name: 'Cucumber', emoji: '🥒', group: _v),
    _ingredient(id: 'lettuce', name: 'Lettuce', emoji: '🥗', group: _v),

    // Fruits
    _ingredient(id: 'banana', name: 'Banana', emoji: '🍌', group: _f),
    _ingredient(id: 'lemon', name: 'Lemon', emoji: '🍋', group: _f),
    _ingredient(id: 'apple', name: 'Apple', emoji: '🍎', group: _f),

    // Proteins
    _ingredient(id: 'egg', name: 'Egg', emoji: '🥚', group: _p),
    _ingredient(id: 'chicken', name: 'Chicken', emoji: '🍗', group: _p),
    _ingredient(id: 'chickpeas', name: 'Chickpeas', emoji: '🫘', group: _p),

    // Other ingredients
    _ingredient(id: 'pasta', name: 'Pasta', emoji: '🍝', group: _o),
    _ingredient(id: 'rice', name: 'Rice', emoji: '🍚', group: _o),
    _ingredient(id: 'bread', name: 'Bread', emoji: '🍞', group: _o),
    _ingredient(id: 'cheese', name: 'Cheese', emoji: '🧀', group: _o),
    _ingredient(id: 'milk', name: 'Milk', emoji: '🥛', group: _o),
    _ingredient(id: 'butter', name: 'Butter', emoji: '🧈', group: _o),
    _ingredient(id: 'cream', name: 'Cream', emoji: '🥛', group: _o),
    _ingredient(id: 'flour', name: 'Flour', emoji: '🌾', group: _o),
    _ingredient(id: 'quinoa', name: 'Quinoa', emoji: '🌾', group: _o),
    _ingredient(id: 'yogurt', name: 'Yogurt', emoji: '🥣', group: _o),
    _ingredient(id: 'basil', name: 'Basil leaves', emoji: '🌿', group: _o),

    // Pantry staples
    _ingredient(
      id: 'olive oil',
      name: 'Olive oil',
      emoji: '🫒',
      group: _o,
      isStaple: true,
    ),
    _ingredient(
      id: 'oil',
      name: 'Cooking oil',
      emoji: '🛢️',
      group: _o,
      isStaple: true,
    ),
    _ingredient(
      id: 'salt & pepper',
      name: 'Salt & pepper',
      emoji: '🧂',
      group: _o,
      isStaple: true,
    ),
    _ingredient(
      id: 'sugar',
      name: 'Sugar',
      emoji: '🍬',
      group: _o,
      isStaple: true,
    ),
    _ingredient(
      id: 'baking powder',
      name: 'Baking powder',
      emoji: '🥄',
      group: _o,
      isStaple: true,
    ),
  ];

  static final Map<String, Ingredient> _byId = {
    for (final ingredient in all) ingredient.id: ingredient,
  };

  /// Ingredients the user can choose from.
  static List<Ingredient> get pickable =>
      all.where((ingredient) => !ingredient.isStaple).toList();

  /// Ingredients displayed on the Home quick-selection grid.
  static List<Ingredient> get quick => [
        'tomato',
        'onion',
        'potato',
        'egg',
        'carrot',
        'spinach',
        'capsicum',
        'garlic',
      ].map((id) => _byId[id]!).toList();

  static Ingredient? byId(String raw) =>
      _byId[normalizeIngredientName(raw)];

  static bool isStaple(String raw) => byId(raw)?.isStaple ?? false;

  /// Searches ingredients by name and optional group.
  static List<Ingredient> search(
    String query, {
    IngredientGroup? group,
  }) {
    final q = normalizeIngredientName(query);

    return pickable.where((ingredient) {
      final groupOk = group == null || ingredient.group == group;
      final textOk = q.isEmpty || ingredient.id.contains(q);
      return groupOk && textOk;
    }).toList();
  }

  /// Converts "Chicken, onion, tomato" into catalog ingredients.
  /// Unknown names are ignored.
  static List<Ingredient> parseList(String text) {
    final result = <Ingredient>[];

    for (final part in text.split(RegExp(r'[,\n]'))) {
      final found = byId(part);

      if (found != null &&
          !found.isStaple &&
          !result.contains(found)) {
        result.add(found);
      }
    }

    return result;
  }
}
