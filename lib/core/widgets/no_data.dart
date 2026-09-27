import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';

import '../styles/app_theme.dart';

class NoDataWidget extends StatelessWidget {
  final String? text;

  const NoDataWidget({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 40,
        ),
        Icon(
          Icons.info_outline_rounded,
          color: Colors.grey.shade400,
          size: 40,
        ),
        const SizedBox(
          height: 15,
        ),
        if (text == null)  Text(
          getTextByKey(key: TranslationKey.keyNoData),
          style: TextStyles.textStyleTitle(context, titleSizeFactor: 0.8),
        ),
        if (text != null) ...[
          const SizedBox(
            height: 8,
          ),
          Text(
            text!,
            textAlign: TextAlign.center,
            style: TextStyles.textStyleTitle(context, titleSizeFactor: 0.6),
          ),
        ],
      ],
    );
  }
}