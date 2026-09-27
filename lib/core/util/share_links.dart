import 'package:share_plus/share_plus.dart';

/// Builds and shares the public, customer-facing website link for a chalet
/// or building — so a guest can send a listing to someone else (WhatsApp,
/// SMS, etc.) straight from the app, without them having to search the
/// site. Mirrors the owner app's identical helper
/// (chaletowner/lib/helper/share_links.dart) so both apps produce the same
/// URLs.
///
/// URLs match the routes in shleeh_com_customer's src/App.jsx exactly:
///   /chalets/:id   → ChaletDetailPage
///   /buildings/:id → BuildingDetailPage
/// The site itself is deployed under the /app subpath (see App.jsx's
/// `Router basename="/app"` comment), not the domain root.
class ShareLinks {
  ShareLinks._();

  static const String _siteBase = 'https://shleeh.com/app';

  static String chaletUrl(int chaletId) => '$_siteBase/chalets/$chaletId';

  static String buildingUrl(int buildingId) =>
      '$_siteBase/buildings/$buildingId';

  /// Opens the native share sheet with a friendly Arabic message + link.
  static Future<void> shareChalet(int chaletId, String name) {
    final label = name.trim().isNotEmpty ? name.trim() : 'الشاليه';
    return Share.share(
      'شاهد $label على شاليه كوم:\n${chaletUrl(chaletId)}',
      subject: label,
    );
  }

  static Future<void> shareBuilding(int buildingId, String name) {
    final label = name.trim().isNotEmpty ? name.trim() : 'المبنى';
    return Share.share(
      'شاهد $label على شاليه كوم:\n${buildingUrl(buildingId)}',
      subject: label,
    );
  }
}
