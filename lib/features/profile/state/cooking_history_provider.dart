import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookingEntry {
  final String recipeId;
  final DateTime cookedAt;
  const CookingEntry(this.recipeId, this.cookedAt);
}

/// Every time the user finishes cooking a recipe it is recorded here.
/// Profile statistics are computed from this real data.
class CookingHistoryProvider extends ChangeNotifier {
  static const storageKey = 'cooking_history';

  final SharedPreferences _prefs;
  final DateTime Function() _now;
  final List<CookingEntry> _entries; // newest first

  CookingHistoryProvider(this._prefs, {DateTime Function()? now})
      : _now = now ?? DateTime.now,
        _entries = _load(_prefs);

  static List<CookingEntry> _load(SharedPreferences prefs) {
    final out = <CookingEntry>[];
    for (final raw in prefs.getStringList(storageKey) ?? const <String>[]) {
      final i = raw.lastIndexOf('|');
      if (i <= 0) continue;
      final ms = int.tryParse(raw.substring(i + 1));
      if (ms == null) continue;
      out.add(CookingEntry(
          raw.substring(0, i), DateTime.fromMillisecondsSinceEpoch(ms)));
    }
    return out;
  }

  List<CookingEntry> get entries => List.unmodifiable(_entries);
  int get totalCooked => _entries.length;
  int get streak => computeStreak(_entries.map((e) => e.cookedAt), _now());

  Future<void> record(String recipeId) async {
    _entries.insert(0, CookingEntry(recipeId, _now()));
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    _entries.clear();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      await _prefs.setStringList(storageKey, [
        for (final e in _entries)
          '${e.recipeId}|${e.cookedAt.millisecondsSinceEpoch}',
      ]);
    } catch (e) {
      debugPrint('Could not save history: $e');
    }
  }

  /// Consecutive days with at least one cooked recipe, ending today (or
  /// yesterday, so the streak is not lost before you cook today).
  static int computeStreak(Iterable<DateTime> dates, DateTime today) {
    final days = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    var cursor = DateTime(today.year, today.month, today.day);
    if (!days.contains(cursor)) {
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    var n = 0;
    while (days.contains(cursor)) {
      n++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return n;
  }
}
