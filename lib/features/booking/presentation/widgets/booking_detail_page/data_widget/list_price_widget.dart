import 'package:flutter/cupertino.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/chalet_detail_page/price_Widgets/price_widget.dart';

class ListPriceWidget extends StatelessWidget {
  const ListPriceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          " ${getTextByKey(
            key: TranslationKey.keyWeekPrices,
          )}",
          style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.8)
              .copyWith(color: primaryColor),
        ),
        PriceWidget(title: "title", price: "30"),
        PriceWidget(title: "title", price: "30"),
        SizedBox(
          height: 15,
        ),
        Text(
          " ${getTextByKey(
            key: TranslationKey.keyWeekendPrices,
          )}",
          style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.8)
              .copyWith(color: primaryColor),
        ),
        PriceWidget(title: "title", price: "30"),
        PriceWidget(title: "title", price: "30"),
      ],
    );
  }
}
