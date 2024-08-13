import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';

import '../util/cashed_data/cashed_file.dart';

class TextIcon extends StatelessWidget {
  final String text;
  final String imagePath;
  TextIcon({required this.text, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyles.textStyleTitle(context),
        ),
        SvgPicture.asset(
          imagePath,
          width: CasheFile.isTablet ? 60 : 30,
          height: CasheFile.isTablet ? 60 : 30,
        )
      ],
    );
  }
}
