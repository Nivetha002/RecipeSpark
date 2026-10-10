import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ingredients/models/ingredient.dart';

class ShoppingItem {
  final String ingredientId;
  final bool checked;
  const ShoppingItem(this.ingredientId, {this.checked = false});
}

/// Missing ingredients the user wants to buy. Saved on the device.
class ShoppingListProvider extends ChangeNotifier {
  static const storageKey = 'shopping_list';

  final SharedPreferences _prefs;
  final List<ShoppingItem> _items;

  ShoppingListProvider(this._prefs) : _items = _load(_prefs);

  static List<ShoppingItem> _load(SharedPreferences prefs) {
    final out = <ShoppingItem>[];
    for (final raw in prefs.getStringList(storageKey) ?? const <String>[]) {
      final i = raw.lastIndexOf('|');
      if (i <= 0) continue;
      out.add(ShoppingItem(raw.substring(0, i), checked: raw.substring(i + 1) == '1'));
    }
    return out;
  }

  List<ShoppingItem> get items => List.unmodifiable(_items);
  int get count => _items.length;

  bool contains(String id) {
    final key = normalizeIngredientName(id);
    return _items.any((e) => e.ingredientId == key);
  }

  /// Adds ingredients that are not already on the list. Returns how many
  /// were actually added.
  int addAll(Iterable<String> ids) {
    var added = 0;
    for (final id in ids) {
      final key = normalizeIngredientName(id);
      if (!contains(key)) {
        _items.add(ShoppingItem(key));
        added++;
      }
    }
    if (added > 0) _changed();
    return added;
  }

  void toggle(String id) {
    final i = _items.indexWhere((e) => e.ingredientId == id);
    if (i < 0) return;
    _items[i] = ShoppingItem(id, checked: !_items[i].checked);
    _changed();
  }

  void remove(String id) {
    _items.removeWhere((e) => e.ingredientId == id);
    _changed();
  }

  void clearChecked() {
    _items.removeWhere((e) => e.checked);
    _changed();
  }

  void clear() {
    _items.clear();
    _changed();
  }

  void _changed() {
    notifyListeners();
    _prefs
        .setStringList(storageKey,
            [for (final e in _items) '${e.ingredientId}|${e.checked ? 1 : 0}'])
        .catchError((Object e) {
      debugPrint('Could not save shopping list: $e');
      return false;
    });
  }
}
