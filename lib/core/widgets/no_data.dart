import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';

import '../styles/app_theme.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key});

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
        Text(
          getTextByKey(key: TranslationKey.keyNoData),
          style: TextStyles.textStyleTitle(context, titleSizeFactor: 0.8),
        )
      ],
    );
  }
}
