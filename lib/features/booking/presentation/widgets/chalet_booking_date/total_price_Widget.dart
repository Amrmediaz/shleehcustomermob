import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/styles/text/text_style.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../chalets/domain/entities/chalet_details_model.dart';
import '../../bloc/bookings/bookings_bloc.dart';

class TotalPriceWidget extends StatelessWidget {
  final dynamic chalet;
  List<Map<String, dynamic>> bookingDaysCalculatePrice;
  dynamic totalBookingPrice;
  dynamic currentPaid;

  TotalPriceWidget({
    super.key,
    required this.chalet,
    required this.bookingDaysCalculatePrice,
    required this.totalBookingPrice,
    required this.currentPaid,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Calculate totals correctly
    double basePrice = double.parse(totalBookingPrice.toString());
    double insurance = chalet.insuranceamount is double ? chalet.insuranceamount : double.parse(chalet.insuranceamount ?? "0");
    double totalWithInsurance = basePrice + insurance;

    // currentPaid already includes insurance if needed
    double paidNow = double.parse(currentPaid.toString());

    return  Directionality(
      textDirection: TextDirection.rtl,child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor, width: 0.5),
          borderRadius: BorderRadius.circular(DEFAULT_CORNER),
          color: Colors.grey.shade50,
        ),
        child: Column(
          children: [
            // ── Days & Base Price ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTextByKey(key: TranslationKey.keyDays),
                      style: TextStyles.textStyleBody(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getTextByKey(key: TranslationKey.keyDaysCost),
                      style: TextStyles.textStyleBody(context),
                    ),
                    if (insurance > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        getTextByKey(key: TranslationKey.keyInsurance),
                        style: TextStyles.textStyleBody(context),
                      ),
                    ],
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${bookingDaysCalculatePrice.length}",
                      style: TextStyles.textStyleBody(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$basePrice ${getTextByKey(key: TranslationKey.keyOMR)}",
                      style: TextStyles.textStyleBody(context),
                    ),
                    if (insurance > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        "$insurance ${getTextByKey(key: TranslationKey.keyOMR)}",
                        style: TextStyles.textStyleBody(context),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Insurance note ──
            if (insurance > 0)
              Wrap(
                children: [
                  Text(
                    "رسوم التأمين مستردة في حالة عدم وجود أي إتلاف لمرافق الشاليه",
                    maxLines: 2,
                    style: TextStyles.textStyleHelper(context).copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // ── Divider ──
            Container(
              color: Colors.grey.shade300,
              height: 0.5,
            ),

            const SizedBox(height: 12),

            // ── Total Price (Base + Insurance) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                  insurance > 0 ? getTextByKey(key: TranslationKey.keyBookingPriceWithInsurance)  :  getTextByKey(key: TranslationKey.keyBookingPrice),
                    style: TextStyles.textStyleBody(context).copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  "$totalWithInsurance ${getTextByKey(key: TranslationKey.keyOMR)}",
                  style: TextStyles.textStyleBody(context).copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),

            const SizedBox(height: 10),

            // ── Amount to Pay Now ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "المبلغ المطلوب دفعه",
                    style: TextStyles.textStyleBody(context).copyWith(
                      color: secondaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  "$paidNow ${getTextByKey(key: TranslationKey.keyOMR)}",
                  style: TextStyles.textStyleBody(context).copyWith(
                    color: secondaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}