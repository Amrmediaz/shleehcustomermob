import 'package:flutter/material.dart';
import 'package:shleehcustomer/features/home_page/presentation/pages/home_page.dart';

import '../../../../../core/util/biometric_auth.dart';
import 'login_page.dart';

/// Dedicated screen for biometric login. Previously the Face ID/fingerprint
/// system prompt was triggered instantly on top of the splash screen (and
/// on the login page's own "login with fingerprint" button), which felt
/// jarring — it covered the branding before it even finished animating in,
/// and there was no visible retry/fallback if the prompt was cancelled or
/// failed. This screen gives it a proper home: a short delay before the
/// prompt fires (so this screen is actually visible first), a clear retry
/// button if it fails, and an explicit "use password instead" fallback.
class BiometricLoginPage extends StatefulWidget {
  const BiometricLoginPage({super.key});

  @override
  State<BiometricLoginPage> createState() => _BiometricLoginPageState();
}

class _BiometricLoginPageState extends State<BiometricLoginPage> {
  bool _isAuthenticating = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // Small delay so this screen actually renders before the native
    // prompt covers it — firing instantly (as it did on the splash
    // screen before) is exactly the jarring behavior this screen fixes.
    Future.delayed(const Duration(milliseconds: 400), _attemptAuth);
  }

  Future<void> _attemptAuth() async {
    if (!mounted) return;
    setState(() {
      _isAuthenticating = true;
      _failed = false;
    });

    final success = await BiometricAuthService.authenticate(
      reason: 'الرجاء تأكيد بصمتك للدخول إلى حسابك',
    );

    if (!mounted) return;

    if (success) {
      // Clears the whole stack (splash/login/etc behind this screen)
      // regardless of which entry point got us here, same as a normal
      // password login does.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else {
      setState(() {
        _isAuthenticating = false;
        _failed = true;
      });
    }
  }

  void _usePasswordInstead() {
    // Always clear the entire stack and land on a fresh LoginPage,
    // regardless of how this screen was reached (splash auto-redirect vs.
    // the login page's own "login with fingerprint" button). A
    // canPop()-based pop() used to be here, but if this screen was ever
    // reached with a stale/inert screen still sitting underneath it, pop()
    // would surface that dead screen instead of a working login form —
    // pushAndRemoveUntil sidesteps that entirely.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // ConstrainedBox + Center (instead of just a Column with
              // mainAxisAlignment.center) is what keeps this truly centered
              // on every screen size: it still centers normally on tall
              // screens, but also scrolls instead of overflowing on short
              // ones (small phones, or with the keyboard/a system banner
              // eating into the available height) rather than clipping.
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.fingerprint, size: 60, color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'الدخول ببصمتك',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isAuthenticating
                              ? 'الرجاء تأكيد بصمتك...'
                              : _failed
                                  ? 'لم يتم التحقق من البصمة'
                                  : 'استخدم بصمة الإصبع أو Face ID لتسجيل الدخول',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),
                        // Visibility(maintainSize: true, ...) instead of a
                        // plain `if` — reserves the button's space even
                        // while it's hidden mid-auth, so the rest of the
                        // content doesn't jump/re-center as the state
                        // changes.
                        Visibility(
                          visible: !_isAuthenticating,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isAuthenticating ? null : _attemptAuth,
                              icon: const Icon(Icons.fingerprint),
                              label: Text(_failed ? 'حاول مرة أخرى' : 'فتح ببصمة الإصبع'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1A1F2E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: _usePasswordInstead,
                          child: const Text('تسجيل الدخول بكلمة المرور', style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
