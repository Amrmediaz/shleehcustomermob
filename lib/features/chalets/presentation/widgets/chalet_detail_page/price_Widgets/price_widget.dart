import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';

import '../../../../../../core/strings/language.dart';

class PriceWidget extends StatelessWidget {
  final String price;
  final String title;
  const PriceWidget({required this.title,required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(6),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: greyColorTxt, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.65),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                price,
                style: TextStyles.textStyleHeadline(context,titleSizeFactor: 0.7)
                    .copyWith(color: yellowAppColor),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                getTextByKey(key: TranslationKey.keyOMR),
                style: TextStyles.textStyleBody(context)
                    .copyWith(color: yellowAppColor),
              ),
            ],
          )
        ],
      ),
    );
  }
}
