import 'package:flutter/material.dart';

import '../styles/app_theme.dart';

/// Small pill showing how a booking was/is being paid, based on the
/// `paymentType` value the backend sends on booking list/details
/// responses — 1 = normal online bank payment, 3 = QPay installments (the
/// same values sent to BookingPayment/BookingPaymentQpay). Renders nothing
/// for any other value (including null), since older bookings and
/// WhatsApp-transfer-confirmed bookings may not have this set at all —
/// showing a wrong/guessed label would be worse than showing nothing.
class PaymentMethodBadge extends StatelessWidget {
  final int? paymentType;

  const PaymentMethodBadge({super.key, required this.paymentType});

  @override
  Widget build(BuildContext context) {
    final _PaymentMethodInfo? info = _infoFor(paymentType);
    if (info == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: info.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 11, color: info.color),
          const SizedBox(width: 4),
          Text(
            info.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: info.color,
            ),
          ),
        ],
      ),
    );
  }

  _PaymentMethodInfo? _infoFor(int? type) {
    switch (type) {
      case 1:
        return _PaymentMethodInfo(
          label: 'دفع عادي',
          icon: Icons.credit_card_rounded,
          color: primaryColor,
        );
      case 3:
        return _PaymentMethodInfo(
          label: 'تقسيط QPay',
          icon: Icons.calendar_view_month_rounded,
          color: const Color(0xFF7C3AED),
        );
      default:
        return null;
    }
  }
}

class _PaymentMethodInfo {
  final String label;
  final IconData icon;
  final Color color;

  const _PaymentMethodInfo({required this.label, required this.icon, required this.color});
}
