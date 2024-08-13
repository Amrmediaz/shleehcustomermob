import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';

import '../../../../../../core/util/enums.dart';

class PaymentMethodWidget extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final bool isSelected;
  const PaymentMethodWidget(
      {required this.paymentMethod, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(DEFAULT_CORNER)),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected ? primaryColor : Colors.grey.shade400,
          ),
          const SizedBox(width: 3),
          paymentMethod == PaymentMethod.onlineBanking
              ? Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               Expanded(child:  Text(
                  getTextByKey(
                      key: paymentMethod == PaymentMethod.onlineBanking
                          ? TranslationKey.keyOnlinePayment
                          : TranslationKey.keyTransferPayment),
                  style: isSelected
                      ? TextStyles.textStyleButton(context, scaleFactor: 0.55)
                      .copyWith(color: primaryColor)
                      : TextStyles.textStyleBody(context)
                      .copyWith(color: Colors.grey.shade500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )),
                const SizedBox(height: 10),
                SvgPicture.asset(AssetsPath.visaImg),
              ],
            ),
          )
              : Expanded(
            child: Text(
              getTextByKey(
                  key: paymentMethod == PaymentMethod.onlineBanking
                      ? TranslationKey.keyOnlinePayment
                      : TranslationKey.keyTransferPayment),
              style: isSelected
                  ? TextStyles.textStyleButton(context, scaleFactor: 0.58)
                  .copyWith(color: primaryColor)
                  : TextStyles.textStyleBody(context)
                  .copyWith(color: Colors.grey.shade500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

  }
}
