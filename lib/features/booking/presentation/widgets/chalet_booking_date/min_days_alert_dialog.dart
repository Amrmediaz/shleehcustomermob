import 'package:flutter/material.dart';

/// Alert shown when the selected date range is shorter than the
/// owner's required minimum number of booking days.
/// Extracted from ChaletBookingDateWidget for reuse/testability.
class MinDaysAlertDialog extends StatelessWidget {
  final String minDays;

  const MinDaysAlertDialog({Key? key, required this.minDays}) : super(key: key);

  static Future<void> show(BuildContext context, String minDays) {
    return showDialog(
      context: context,
      builder: (_) => MinDaysAlertDialog(minDays: minDays),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
              child: Icon(Icons.info_rounded, color: Colors.orange.shade700, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'الحد الأدنى للحجز',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F2E)),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'يجب حجز ',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.6),
                  ),
                  TextSpan(
                    text: '$minDays أيام',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                    ),
                  ),
                  TextSpan(
                    text: ' على الأقل\nكشرط من شروط الحجز من قبل المالك',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1F2E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('حسناً'),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}