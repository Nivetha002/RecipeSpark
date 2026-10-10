
/// Optional photo URLs for recipes and ingredients.
/// If a URL is missing or its image fails to load,
/// FoodImage displays the local asset or emoji fallback.

const Map<String, String> kRecipeImages = {};

const Map<String, String> kIngredientImages = {
  // Vegetables
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

  // Fruits
  'banana':
      'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300&h=300&fit=crop',
  'lemon':
      'https://images.unsplash.com/photo-1513558161293-cdaf765edfd7?w=300&h=300&fit=crop',
  'apple':
      'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=300&h=300&fit=crop',

  // Proteins
  'egg':
      'https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=300&h=300&fit=crop',
  'chicken':
      'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=300&h=300&fit=crop',
  'chickpeas':
      'https://images.unsplash.com/photo-1515543904379-3d757afe72e4?w=300&h=300&fit=crop',

  // Other ingredients
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

