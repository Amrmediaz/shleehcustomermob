import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/action_btn.dart';

class SupportBtn extends StatelessWidget {
  const SupportBtn({super.key});

  // Define constant support data
  static const String _phoneNumber = "+96893866893";
  static const String _supportMessage = "السلام عليكم\nعندي استفسار بخصوص الخدمة";

  /// Attempts to open WhatsApp directly, falls back to clipboard if failed
  Future<void> _redirectToWhatsApp(BuildContext context) async {
    // Clean phone number for URL format (remove + or spaces if necessary, keeping digits)
    final cleanPhone = _phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final encodedMessage = Uri.encodeComponent(_supportMessage);

    // Fallback URL (whatsapp://) works beautifully on mobile apps
    final whatsappUrl = Uri.parse("whatsapp://send?phone=$cleanPhone&text=$encodedMessage");
    // Web fallback just in case
    final whatsappWebUrl = Uri.parse("https://wa.me/$cleanPhone?text=$encodedMessage");

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(whatsappWebUrl)) {
        await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp channels';
      }
    } catch (e) {
      // Fallback: Copy info to clipboard if WhatsApp isn't installed or fails to open
      if (context.mounted) {
        _copyToClipboardAndShowSnackBar(context);
      }
    }
  }

  void _copyToClipboardAndShowSnackBar(BuildContext context) {
    final combinedText = "رقم الدعم: $_phoneNumber\n\n$_supportMessage";
    Clipboard.setData(ClipboardData(text: combinedText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'لم نتمكن من فتح واتساب. تم نسخ رقم الدعم ونص الرسالة تلقائياً!',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
          ),
        ),
        backgroundColor: Colors.grey.shade900,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildSettingItem(
          context: context,
          icon: CupertinoIcons.bubble_left_bubble_right_fill,
          title: getTextByKey(key: TranslationKey.keyContactSupport),
          subtitle: 'احصل على المساعدة المباشرة عبر واتس آب',
          onTap: () => _redirectToWhatsApp(context), // ✅ Goes directly now
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFirst ? 16 : 0),
          topRight: Radius.circular(isFirst ? 16 : 0),
          bottomLeft: Radius.circular(isLast ? 16 : 0),
          bottomRight: Radius.circular(isLast ? 16 : 0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Arrow icon
              Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 14),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.red.shade600
                            : Colors.grey.shade900,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.shade50
                      : primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: isDestructive ? Colors.red.shade600 : primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}