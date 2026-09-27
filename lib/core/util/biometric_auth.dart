import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around local_auth — checks device support/enrollment and
/// runs the native Face ID / fingerprint prompt. Never throws: every method
/// returns a plain bool so callers don't need try/catch at every call site.
/// Mirrors chaletowner's identical helper (lib/helper/biometric_auth.dart)
/// so both apps behave the same way.
class BiometricAuthService {
  BiometricAuthService._();

  static final LocalAuthentication _auth = LocalAuthentication();

  /// True only if the device hardware supports biometrics AND the guest has
  /// actually enrolled a fingerprint/face — offering the feature on a
  /// device with nothing enrolled would just fail every time it's used.
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Runs the native biometric prompt. Returns false (never throws) on any
  /// failure, cancel, or lockout so callers can just check a bool.
  static Future<bool> authenticate({
    String reason = 'الرجاء تأكيد هويتك للمتابعة',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

/// Shared preference keys/helpers for the biometric-login flags. Kept in
/// one place since three different screens (login, splash, settings) all
/// need to read/write the same flags. Deliberately a separate small store
/// rather than going through CasheFile — these flags are unrelated to the
/// account session data CasheFile manages (token/profile/isLogin), and
/// keeping them independent means clearing the session on logout doesn't
/// accidentally wipe a device-level preference like "this phone unlocks
/// with a fingerprint."
class BiometricPrefs {
  BiometricPrefs._();

  static const _kEnabledKey = 'biometricEnabled';
  static const _kAskedKey = 'biometricAsked';
  static const _kPayEnabledKey = 'biometricPayEnabled';

  /// Whether the guest has turned fingerprint/Face ID login on.
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, value);
  }

  /// Whether the guest wants to require a fingerprint/Face ID check right
  /// before moving into the payment step of booking. Deliberately a
  /// separate flag from [isEnabled] (the login one) — a guest may want one
  /// without the other, e.g. no biometric login but still wants a
  /// fingerprint check before spending money.
  static Future<bool> isPayEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPayEnabledKey) ?? false;
  }

  static Future<void> setPayEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPayEnabledKey, value);
  }

  /// Whether the one-time "enable fingerprint login?" prompt has already
  /// been shown after a password login — so it only asks once, not on
  /// every single login, and stays out of the way once dismissed. The
  /// setting is still reachable any time from the settings screen.
  static Future<bool> wasAsked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kAskedKey) ?? false;
  }

  static Future<void> markAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAskedKey, true);
  }
}
