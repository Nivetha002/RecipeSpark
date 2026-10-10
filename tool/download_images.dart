// Downloads real food photos from Pexels into assets/images/.
//
// Usage (run from the project root, next to pubspec.yaml):
//   PowerShell:  $env:PEXELS_API_KEY="your_key_here"
//                dart run tool/download_images.dart --overwrite
//   macOS/Linux: PEXELS_API_KEY=your_key dart run tool/download_images.dart --overwrite
//
// The key is only read from your environment. It is NOT stored in the app.
// Photos are free to use under the Pexels licence; credits are written to
// assets/images/CREDITS.txt.
import 'dart:convert';
import 'dart:io';

const recipes = <String, String>{
  'creamy_tomato_pasta': 'creamy tomato pasta bowl',
  'garden_salad': 'fresh garden salad bowl',
  'fluffy_pancakes': 'stack of pancakes',
  'grilled_chicken_bowl': 'grilled chicken rice bowl',
  'vegetable_stir_fry': 'vegetable stir fry',
  'veggie_omelette': 'vegetable omelette',
  'quinoa_salad': 'quinoa salad',
  'banana_smoothie': 'banana smoothie glass',
  'egg_fried_rice': 'egg fried rice',
  'crispy_potato_wedges': 'potato wedges',
  'garlic_mushroom_toast': 'mushroom toast',
};

// ingredient id -> search words (ids must match IngredientCatalog).
const ingredients = <String, String>{
  'tomato': 'tomatoes',
  'onion': 'red onion',
  'potato': 'potatoes',
  'carrot': 'carrots',
  'spinach': 'spinach leaves',
  'capsicum': 'bell peppers',
  'garlic': 'garlic bulbs',
  'mushroom': 'mushrooms',
  'broccoli': 'broccoli',
  'corn': 'corn cob',
  'zucchini': 'zucchini',
  'cucumber': 'cucumber',
  'lettuce': 'lettuce',
  'banana': 'bananas',
  'lemon': 'lemons',
  'apple': 'red apple',
  'egg': 'eggs',
  'chicken': 'raw chicken breast',
  'chickpeas': 'chickpeas',
  'pasta': 'dry pasta',
  'rice': 'white rice',
  'bread': 'bread slices',
  'cheese': 'cheese block',
  'milk': 'glass of milk',
  'butter': 'butter',
  'cream': 'cream',
  'flour': 'flour',
  'quinoa': 'quinoa',
  'yogurt': 'yogurt bowl',
  'basil': 'basil leaves',
};

Future<void> main(List<String> args) async {
  final key = Platform.environment['PEXELS_API_KEY'];
  if (key == null || key.isEmpty) {
    stderr.writeln('Set PEXELS_API_KEY first (free at https://www.pexels.com/api/).');
    exit(1);
  }
  final overwrite = args.contains('--overwrite');
  final client = HttpClient();
  final credits = StringBuffer();

  Directory('assets/images/recipes').createSync(recursive: true);
  Directory('assets/images/ingredients').createSync(recursive: true);

  var ok = 0, failed = <String>[];

  Future<void> fetch(String id, String query, String folder, String ext,
      String orientation, String size) async {
    final path = 'assets/images/$folder/$id.$ext';
    if (!overwrite && File(path).existsSync()) {
      print('skip   $path (exists)');
      return;
    }
    try {
      final photo = await _search(client, key, query, orientation);
      if (photo == null) {
        failed.add(id);
        print('FAILED $id (no result for "$query")');
        return;
      }
      final url = (photo['src'] as Map)[size] as String;
      await File(path).writeAsBytes(await _download(client, url));
      credits.writeln(
          '$path - ${photo['photographer']} - ${photo['url']}');
      ok++;
      print('ok     $path');
    } catch (e) {
      failed.add(id);
      print('FAILED $id: $e');
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  for (final e in recipes.entries) {
    await fetch(e.key, '${e.value} food', 'recipes', 'jpg', 'landscape', 'large');
  }
  for (final e in ingredients.entries) {
    // Saved as .png to match the app; Flutter reads the real format from the
    // file contents, so JPEG data inside a .png name still displays fine.
    await fetch(e.key, '${e.value} white background', 'ingredients', 'png',
        'square', 'medium');
  }

  if (credits.isNotEmpty) {
    File('assets/images/CREDITS.txt')
        .writeAsStringSync('Photos from Pexels (pexels.com)\n\n$credits');
  }
  client.close();
  print('\nDone: $ok downloaded, ${failed.length} failed ${failed.isEmpty ? '' : failed}');
}

Future<Map<String, dynamic>?> _search(
    HttpClient c, String key, String query, String orientation) async {
  final uri = Uri.https('api.pexels.com', '/v1/search', {
    'query': query,
    'per_page': '3',
    'orientation': orientation,
  });
  final req = await c.getUrl(uri);
  req.headers.set('Authorization', key);
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  if (res.statusCode != 200) {
    throw 'Pexels returned ${res.statusCode}: $body';
  }
  final photos = (jsonDecode(body) as Map)['photos'] as List;
  return photos.isEmpty ? null : Map<String, dynamic>.from(photos.first as Map);
}

Future<List<int>> _download(HttpClient c, String url) async {
  final res = await (await c.getUrl(Uri.parse(url))).close();
  if (res.statusCode != 200) throw 'Download failed (${res.statusCode})';
  final bytes = <int>[];
  await for (final chunk in res) {
    bytes.addAll(chunk);
  }
  return bytes;
}
