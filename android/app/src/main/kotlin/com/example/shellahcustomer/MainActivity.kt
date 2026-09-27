package com.shellahadmin.shellahcustomer

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (not the default FlutterActivity) is required by
// local_auth on Android — it needs a FragmentActivity to host the native
// biometric prompt (BiometricPrompt API).
class MainActivity: FlutterFragmentActivity() {
}
