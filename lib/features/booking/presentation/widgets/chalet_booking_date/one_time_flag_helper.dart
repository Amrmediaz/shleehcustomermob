import 'package:shared_preferences/shared_preferences.dart';

/// Small helper that decides whether a "seen once" flag has already
/// been set in SharedPreferences, and sets it.
/// Extracted so the widget doesn't own SharedPreferences plumbing directly.
class OneTimeFlagHelper {
  final String prefsKey;

  const OneTimeFlagHelper(this.prefsKey);

  Future<bool> hasBeenSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey) ?? false;
  }

  Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
  }
}