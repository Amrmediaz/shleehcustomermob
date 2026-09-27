import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';

import '../../../../../../core/util/enums.dart';

// Redesigned as a proper "method card": icon badge + title/subtitle instead
// of a single line of text, so all 3 options (online banking, QPay,
// transfer) read consistently instead of QPay being the only one with a
// description. Also supports a disabled state (used when the 25% deposit
// is selected — QPay/installments requires paying the full amount, see
// BookingChaletForm).
class PaymentMethodWidget extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final bool isSelected;
  final bool isDisabled;
  const PaymentMethodWidget({
    required this.paymentMethod,
    required this.isSelected,
    this.isDisabled = false,
  });

  String get _labelKey {
    switch (paymentMethod) {
      case PaymentMethod.onlineBanking:
        return TranslationKey.keyOnlinePayment;
      case PaymentMethod.qpay:
        return TranslationKey.keyQpayLabel;
      case PaymentMethod.transferBanking:
        return TranslationKey.keyTransferPayment;
    }
  }

  String get _descKey {
    switch (paymentMethod) {
      case PaymentMethod.onlineBanking:
        return TranslationKey.keyOnlinePaymentDesc;
      case PaymentMethod.qpay:
        return TranslationKey.keyQpayDesc;
      case PaymentMethod.transferBanking:
        return TranslationKey.keyTransferPaymentDesc;
    }
  }

  IconData get _icon {
    switch (paymentMethod) {
      case PaymentMethod.onlineBanking:
        return Icons.credit_card_rounded;
      case PaymentMethod.qpay:
        return Icons.calendar_view_month_rounded;
      case PaymentMethod.transferBanking:
        return Icons.account_balance_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = isSelected && !isDisabled;
    return Opacity(
      opacity: isDisabled ? 0.45 : 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(DEFAULT_CORNER)),
          border: Border.all(
            color: selected ? primaryColor : Colors.grey.shade300,
            width: selected ? 1.6 : 1,
          ),
          color: selected ? primaryColor.withOpacity(0.05) : Colors.white,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.14),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected ? primaryColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _icon,
                color: selected ? Colors.white : Colors.grey.shade500,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getTextByKey(key: _labelKey),
                    style: TextStyles.textStyleTitle(context).copyWith(
                      color: selected ? primaryColor : appTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    getTextByKey(key: _descKey),
                    style: TextStyles.textStyleHelper(context, scaleFactor: 0.42)
                        .copyWith(color: Colors.grey.shade500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (paymentMethod == PaymentMethod.onlineBanking) ...[
              const SizedBox(width: 8),
              SvgPicture.asset(AssetsPath.visaImg, height: 18),
            ],
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? primaryColor : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
