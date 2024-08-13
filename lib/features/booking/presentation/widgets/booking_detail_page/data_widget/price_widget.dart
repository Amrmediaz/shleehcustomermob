import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';

import '../../../../../../core/strings/language.dart';

class BookingDataWidget extends StatelessWidget {
  final String data;
  final String title;
  const BookingDataWidget({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(margin:const EdgeInsets.symmetric(horizontal: 15,vertical: 10) ,child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(
          title,
          style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.6).copyWith(color: primaryColor),
        )),
        Container(
          padding: const EdgeInsets.all(5),
          decoration:  BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(DEFAULT_CORNER - 3)) ,  color: Colors.grey.shade50,),

          child: Text(
            data,
            style: TextStyles.textStyleBody(context)
                .copyWith(color: Colors.black),
          ),
        )
      ],
    ));
  }
}
