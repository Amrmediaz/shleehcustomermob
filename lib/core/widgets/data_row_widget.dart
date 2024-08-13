import 'package:flutter/cupertino.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';

class DataRowIcon extends StatelessWidget {
  final String text;
  final Icon icon;
  DataRowIcon({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [ icon ,const SizedBox(width: 15,), Text(text,style: TextStyles.textStyleBody(context),),]
    );
  }
}
