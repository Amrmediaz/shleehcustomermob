import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/util/Constants.dart';

import '../../../../../core/styles/text/text_style.dart';

class SettingDataRow extends StatelessWidget {
  Function onPressed;
  final String text;
  final String imagePath;
  SettingDataRow({super.key, required this.text, required this.imagePath , required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return  InkWell(

      onTap: () { onPressed(); },
      child:   Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius:
              const BorderRadius.all(Radius.circular(DEFAULT_CORNER))),
      child:  Row(
        children: [
          SvgPicture.asset(imagePath),
          const SizedBox(width: 7,),
          Text(
            text,
            style: TextStyles.textStyleBody(context),
          ),

        ],
      )),
    );
  }
}
