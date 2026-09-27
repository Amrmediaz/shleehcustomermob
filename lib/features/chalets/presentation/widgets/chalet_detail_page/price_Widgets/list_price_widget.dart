import 'package:flutter/cupertino.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/chalet_detail_page/price_Widgets/price_widget.dart';

import '../../../../domain/entities/chalet_details_model.dart';

class ListPriceWidget extends StatelessWidget {
  final ChaletDetails chalet;

  ListPriceWidget({required this.chalet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          " ${getTextByKey(
            key: TranslationKey.keyWeekPrices,
          )}",
          style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.7)
              .copyWith(color: primaryColor),
        ),
        PriceWidget(title: getTextByKey(key: TranslationKey.keyFullDay), price: chalet.rentFullday),
        chalet.rentHalfday != ""
            ? PriceWidget(title: getTextByKey(key: TranslationKey.keyHalfDay), price: chalet.rentHalfday)
            : Container(),
        const SizedBox(
          height: 15,
        ),
        Text(
          " ${getTextByKey(
            key: TranslationKey.keyWeekendPrices,
          )}",
          style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.7)
              .copyWith(color: primaryColor),
        ),
        chalet.offDayPriceFullday != ""
            ? PriceWidget(title: getTextByKey(key: TranslationKey.keyFullDay), price: chalet.offDayPriceFullday)
            : Container(),
        chalet.offDayPriceHalfday != ""
            ? PriceWidget(title: getTextByKey(key: TranslationKey.keyHalfDay), price: chalet.offDayPriceHalfday)
            : Container(),
      ],
    );
  }
}
