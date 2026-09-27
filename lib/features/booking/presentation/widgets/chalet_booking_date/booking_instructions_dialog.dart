import 'package:flutter/material.dart';

import '../../../../../core/styles/app_theme.dart';

/// Small reusable UI piece used inside [BookingInstructionsDialog].
/// Represents a single numbered instruction card (e.g. "1. Single day booking").
class _InstructionCard extends StatelessWidget {
  final String title;
  final String description;
  final String number;
  final Color badgeColor;
  final Color badgeTextColor;

  const _InstructionCard({
    required this.title,
    required this.description,
    required this.number,
    required this.badgeColor,
    required this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}

/// Dialog explaining how to book a single day vs a date range.
/// Extracted from ChaletBookingDateWidget so it can be reused/tested on its own.
class BookingInstructionsDialog extends StatelessWidget {
  const BookingInstructionsDialog({Key? key}) : super(key: key);

  /// Shows the dialog. Kept as a static helper so callers don't need to
  /// import Dialog-building boilerplate.
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const BookingInstructionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _InstructionCard(
                title: 'حجز يوم واحد',
                description: 'اضغط على نفس اليوم مرتين في التقويم',
                number: '1',
                badgeColor: Colors.blue.shade100,
                badgeTextColor: Colors.blue.shade700,
              ),
              const SizedBox(height: 12),
              _InstructionCard(
                title: 'حجز عدة  أيام',
                description: 'اختر يومين مختلفين (تاريخ البداية والنهاية)',
                number: '2',
                badgeColor: Colors.green.shade100,
                badgeTextColor: Colors.green.shade700,
              ),
              const SizedBox(height: 24),
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(Icons.calendar_month_rounded, color: primaryColor, size: 28),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Text(
              'كيفية الحجز',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'فهمت، ابدأ الحجز',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}