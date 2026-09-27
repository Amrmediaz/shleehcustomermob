import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';

import '../../../../domain/entities/special_price_range.dart';

/// Shows the selected check-in / check-out dates as a single connected
/// card - both dates side by side with an arrow between them, and the
/// nights count underneath.
///
/// Renders once the check-in date is picked. The check-out side stays
/// blank (a placeholder dash) until the user actually picks a different
/// check-out date - it no longer mirrors check-in.
class CheckInOutSummary extends StatelessWidget {
  final List<DateTime?> dates;
  final bool isFullDay;

  const CheckInOutSummary({
    Key? key,
    required this.dates,
    required this.isFullDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dates.isEmpty || dates[0] == null) return const SizedBox.shrink();

    final DateTime checkIn = dates[0]!;

    // Half-day booking: single date, no check-in/check-out range.
    if (!isFullDay) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withOpacity(0.25), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _DateColumn(
                label: 'تاريخ الحجز',
                date: checkIn,
                alignment: CrossAxisAlignment.center,
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 10),
              Text(
                'حجز نص يوم',
                style: TextStyles.textStyleHelper(context, scaleFactor: 0.65).copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final DateTime? checkOut = dates.length > 1 ? dates[1] : null;
    final int? nights = checkOut != null ? checkOut.difference(checkIn).inDays : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _DateColumn(
                    label: 'تسجيل الوصول',
                    date: checkIn,
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
                _Connector(),
                Expanded(
                  child: _DateColumn(
                    label: 'تسجيل المغادرة',
                    date: checkOut,
                    alignment: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 10),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                nights == null
                    ? 'اختر تاريخ المغادرة'
                    : (nights <= 1 ? 'ليلة واحدة' : '$nights ليالي'),
                style: TextStyles.textStyleHelper(context, scaleFactor: 0.65).copyWith(
                  color: nights == null ? Colors.grey.shade400 : primaryColor,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final DateTime? date;
  final CrossAxisAlignment alignment;

  const _DateColumn({
    required this.label,
    required this.date,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            label,
            style: TextStyles.textStyleHelper(context, scaleFactor: 0.6)
                .copyWith(color: Colors.grey.shade500),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          date != null ? formatDateYyyyMmDd(date!) : '—',
          style: TextStyles.textStyleBody(context).copyWith(
            color: date != null ? Colors.black87 : Colors.grey.shade400,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_forward_rounded, color: primaryColor, size: 16),
      ),
    );
  }
}