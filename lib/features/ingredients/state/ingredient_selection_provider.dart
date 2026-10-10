import 'package:flutter/foundation.dart';

import '../models/ingredient.dart';

/// Ingredients the user currently has. Shared by Home and the dedicated
/// Select Ingredients screen, so both always show the same selection.
class IngredientSelectionProvider extends ChangeNotifier {
  final Set<String> _selected = {};

  Set<String> get selected => Set.unmodifiable(_selected);
  int get count => _selected.length;
  bool get isEmpty => _selected.isEmpty;

  bool isSelected(String id) => _selected.contains(normalizeIngredientName(id));

  void toggle(String id) {
    final key = normalizeIngredientName(id);
    if (!_selected.remove(key)) _selected.add(key);
    notifyListeners();
  }

  void addAll(Iterable<String> ids) {
    _selected.addAll(ids.map(normalizeIngredientName));
    notifyListeners();
  }

  void clear() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }
}
