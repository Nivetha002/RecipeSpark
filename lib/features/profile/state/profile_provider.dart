import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local display name. There is no account system yet: everyone is a guest
/// and data stays on this device.
class ProfileProvider extends ChangeNotifier {
  static const nameKey = 'profile_name';
  final SharedPreferences _prefs;
  String _name;

  ProfileProvider(this._prefs) : _name = _prefs.getString(nameKey) ?? '';

  String get name => _name;
  bool get hasName => _name.isNotEmpty;
  String get displayName => hasName ? _name : 'Guest Cook';

  Future<void> setName(String value) async {
    _name = value.trim();
    notifyListeners();
    try {
      if (_name.isEmpty) {
        await _prefs.remove(nameKey);
      } else {
        await _prefs.setString(nameKey, _name);
      }
    } catch (e) {
      debugPrint('Could not save name: $e');
    }
  }
}
