import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';

/// Shown wherever a bloc lands in an Error state. Previously this was just
/// a wall of 25px text with no way out except leaving the screen — now it
/// also shows an icon and, if [onRetry] is given, a Retry button so the
/// user can recover in place instead of navigating back and in again.
class MessageDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const MessageDisplayWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.grey.shade400,
                size: 40,
              ),
              const SizedBox(height: 15),
              Text(
                message,
                style: TextStyles.textStyleTitle(context, titleSizeFactor: 0.8),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(getTextByKey(key: TranslationKey.keyRetry)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
