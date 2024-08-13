import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/chalet_detail_page/price_Widgets/price_widget.dart';
import 'package:http/http.dart' as http;

import '../../../../domain/entities/chalet_details_model.dart';
class ListPriceWidget extends StatefulWidget {

  final ChaletDetails chalet;
  ListPriceWidget({required this.chalet});

  @override
  State<ListPriceWidget> createState() => _ListPriceWidgetState();
}

class _ListPriceWidgetState extends State<ListPriceWidget> {
  List<dynamic> _priceList = [];
  @override
  void initState() {
    super.initState();

    _fetchBuildingPrices();
  }
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
        PriceWidget(title: getTextByKey(key: TranslationKey.keyFullDay), price:   widget.chalet.rentFullday),
        widget.chalet.rentHalfday != ""
            ? PriceWidget(title: getTextByKey(key: TranslationKey.keyHalfDay), price:   widget.chalet.rentHalfday)
            : Container(),
        const SizedBox(
          height: 15,
        ),
        // widget.chalet.offDayPriceHalfday != "" ? Text(
        //   " ${getTextByKey(
        //     key: TranslationKey.keyWeekendPrices,
        //   )}",
        //   style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.7)
        //       .copyWith(color: primaryColor),
        // ) : Container(),
        // widget.chalet.offDayPriceFullday != ""
        //     ? PriceWidget(title: getTextByKey(key: TranslationKey.keyFullDay), price:   widget.chalet.offDayPriceFullday)
        //     : Container(),
        // widget.chalet.offDayPriceHalfday != ""
        //     ? PriceWidget(title: getTextByKey(key: TranslationKey.keyHalfDay), price:   widget.chalet.offDayPriceHalfday)
        //     : Container(),
        _priceList.isEmpty ? Container() :  Text('الأسعار الخاصة:', style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.7).copyWith(color: primaryColor)),
        ..._priceList.map((price) {
          return Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              // color: Colors.grey.shade50,
              borderRadius: BorderRadius.all(Radius.circular(12)),
              border: Border.all(color: primaryColor,width: 0.3)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: 20),
                    if (price['day'] != null)
                      Text(dayTranslations[price['day']]! , style:  TextStyles.textStyleTitle(context),),
                    price['type'] == 2 ?  Row(
                      children: [

                        Text('من' , style:  TextStyles.textStyleBody(context),),
                        SizedBox(width: 5),
                        if (price['startDate'] != null)
                          Text(
                            '${price['startDate']}',
                            style:  TextStyles.textStyleTitle(context),
                          ),
                        SizedBox(width: 5),
                        Text('إلى' , style:  TextStyles.textStyleBody(context),),
                        SizedBox(width: 5),
                        if (price['endDate'] != null)
                          Text(
                            '${price['endDate']}',
                            style:  TextStyles.textStyleTitle(context),
                          ),

                      ],
                    ):
                    Container() ,



                  ],
                ),
                Row(
                  children: [
                    Text('السعر: ${price['price']}  ريال ' , style:  TextStyles.textStyleBody(context),),


                  ],
                ),

              ],
            ),
          );
        }).toList()
      ],
    );;
  }
  Future<void> _fetchBuildingPrices() async {
    final response = await http.get(
      Uri.parse(
          'https://shleeh.com/api/Owners/GetBuildingPrices?BuldingId=${widget.chalet.id}'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      print(response.body);
      final data = json.decode(response.body);
      if (data['status']) {
        setState(() {
          _priceList = data['message'];
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب الأسعار')),
      );
    }
  }
}

  Map<String, String> dayTranslations = {
    "friday": "الجمعة",
    "sunday": "الأحد",
    "monday": "الاثنين",
    "tuesday": "الثلاثاء",
    "wednesday": "الأربعاء",
    "thursday": "الخميس",
    "saturday": "السبت",
  };




