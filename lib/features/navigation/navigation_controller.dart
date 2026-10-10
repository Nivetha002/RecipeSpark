import 'package:flutter/foundation.dart';

/// Which bottom-navigation tab is open (0 Home, 1 Explore, 2 Saved,
/// 3 Assistant), plus a search text Home can hand to Explore.
class NavigationController extends ChangeNotifier {
  int _index = 0;
  String _exploreQuery = '';
  int _exploreTick = 0;

  int get index => _index;
  String get exploreQuery => _exploreQuery;

  /// Increases every time Home asks Explore to open, so Explore can tell a
  /// new request from an old one even when the text is the same.
  int get exploreTick => _exploreTick;

  void setIndex(int i) {
    if (i == _index) return;
    _index = i;
    notifyListeners();
  }

  void openExplore({String query = ''}) {
    _exploreQuery = query.trim();
    _exploreTick++;
    _index = 1;
    notifyListeners();
  }
}
