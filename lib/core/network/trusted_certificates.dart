import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

/// Workaround for HandshakeException: CERTIFICATE_VERIFY_FAILED
/// ("unable to get local issuer certificate") seen on some Android devices
/// (reported on Xiaomi/MIUI) when calling the shleeh.com API.
///
/// Root cause (confirmed via SSL Labs + the device's own logcat output):
/// www.shleeh.com's server only sends its leaf certificate plus the
/// "Sectigo Public Server Authentication CA DV R36" intermediate. It never
/// sends the root ("Sectigo Public Server Authentication Root R46"), so any
/// client whose local trust store doesn't already have that root (some
/// Android builds, and Dart's own bundled root set depending on SDK
/// version) can't complete the chain and the handshake fails outright.
///
/// The correct long-term fix is on the server: it should serve the full
/// certificate chain (or the legacy cross-signed variant) so every client
/// can validate it. Until that's done, this adds the missing root as an
/// explicitly trusted certificate on the Dart/Flutter side, so the app's
/// HTTP calls succeed regardless of the server or device's own trust store.
///
/// This must run before any network call is made (call it once at app
/// startup, before `runApp`).
Future<void> registerTrustedCertificates() async {
  try {
    final certData = await rootBundle.load(
      'assets/certs/sectigo_public_server_authentication_root_r46.pem',
    );
    SecurityContext.defaultContext.setTrustedCertificatesBytes(
      certData.buffer.asUint8List(),
    );
  } catch (e) {
    // Never block app startup over this — worst case we're back to
    // relying on the device/runtime's own trust store, same as before.
    // ignore: avoid_print
    print('⚠️ registerTrustedCertificates failed: $e');
  }
}
