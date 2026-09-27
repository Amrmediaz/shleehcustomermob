import 'package:flutter/cupertino.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/features/buildings/presentation/widgets/building_detail_page/price_Widgets/price_widget.dart';

import '../../../../domain/entities/Building_details_model.dart';

class ListPriceWidget extends StatelessWidget {
  final BuildingDetails Building;

  ListPriceWidget({required this.Building});

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
        PriceWidget(title: getTextByKey(key: TranslationKey.keyFullDay), price: Building.name),
        Building.name != ""
            ? PriceWidget(title: getTextByKey(key: TranslationKey.keyHalfDay), price: Building.name)
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
        Building.name != ""
            ? PriceWidget(title: getTextByKey(key: TranslationKey.keyFullDay), price: Building.name)
            : Container(),
        Building.name != ""
            ? PriceWidget(title: getTextByKey(key: TranslationKey.keyHalfDay), price: Building.name)
            : Container(),
      ],
    );
  }
}
