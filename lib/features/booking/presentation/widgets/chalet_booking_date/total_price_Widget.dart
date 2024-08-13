import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/styles/text/text_style.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../chalets/domain/entities/chalet_details_model.dart';
import '../../bloc/bookings/bookings_bloc.dart';

class TotalPriceWidget extends StatelessWidget {
  final ChaletDetails chalet;
  List<Map<String, dynamic>> bookingDaysCalculatePrice ;
  dynamic totalBookingPrice;
  dynamic currentPaid;

  TotalPriceWidget({super.key, required this.chalet , required this.bookingDaysCalculatePrice , required this.totalBookingPrice , required this.currentPaid});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 0.3),
            borderRadius: const BorderRadius.all(
                Radius.circular(DEFAULT_CORNER)),
            color: Colors.grey.shade50),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      " ${getTextByKey(key: TranslationKey.keyDays)}",
                      style: TextStyles.textStyleBody(context),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      " ${getTextByKey(key: TranslationKey.keyDaysCost)}",
                      style: TextStyles.textStyleBody(context),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    chalet.insuranceamount != "0.0"
                        ? Text(
                      getTextByKey(
                          key: TranslationKey
                              .keyInsurance),
                      style: TextStyles.textStyleBody(
                          context),
                    )
                        : Container(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${bookingDaysCalculatePrice.length}",
                      style: TextStyles.textStyleTitle(context),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "$totalBookingPrice ${getTextByKey(key: TranslationKey.keyOMR)}",
                      style: TextStyles.textStyleTitle(context),
                    ),
                    chalet.insuranceamount != "0.0"
                        ? const SizedBox(
                      height: 4,
                    )
                        : Container(),
                    chalet.insuranceamount != "0.0"
                        ? Text(
                      "${chalet.insuranceamount} ${getTextByKey(key: TranslationKey.keyOMR)}",
                      style: TextStyles.textStyleTitle(
                          context),
                    )
                        : Container(),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            chalet.insuranceamount != "0.0"
                ? Wrap(
              children: [
                Text(
                  "رسوم التأمين مستردة في حالة عدم وجود أي إتلاف لمرافق الشاليه",
                  maxLines: 2,
                  style:
                  TextStyles.textStyleHelper(context)
                      .copyWith(
                      color:
                      Colors.grey.shade600),
                ),
              ],
            )
                : Container(),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.grey,
              ),
              width: MediaQuery.of(context).size.width / 1.2,
              height: 0.5,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(
                  getTextByKey(
                      key: TranslationKey.keyBookingPrice),
                  style: TextStyles.textStyleTitle(context)
                      .copyWith(color: primaryColor),
                )),
                Text(
                  "${ (totalBookingPrice + (double.parse(chalet.insuranceamount)) ?? 0.0  )} ${getTextByKey(key: TranslationKey.keyOMR)}",
                  style: TextStyles.textStyleTitle(context)
                      .copyWith(color: primaryColor),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(
                  getTextByKey(
                      key: TranslationKey.keyBookingPriceAfterDeposit),
                  style: TextStyles.textStyleTitle(context)
                      .copyWith(color: secondaryColor),
                )),
                Text(
                  "${ currentPaid + (double.parse(chalet.insuranceamount)) ?? 0.0} ${getTextByKey(key: TranslationKey.keyOMR)}",
                  style: TextStyles.textStyleTitle(context)
                      .copyWith(color: secondaryColor),
                )
              ],
            ),

          ],
        ));
  }

}
