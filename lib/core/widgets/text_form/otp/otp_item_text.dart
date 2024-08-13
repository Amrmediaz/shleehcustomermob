import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:flutter/material.dart';

import '../../../strings/language.dart';
import '../../../util/Constants.dart';

class OtpItemWidget extends StatelessWidget {
  final TextEditingController pinController ;
  final FocusNode pinCurrentFocus;
  final FocusNode pinNextFocuss ;

  const OtpItemWidget({required this.pinController, required this.pinCurrentFocus , required this.pinNextFocuss});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: pinController,
        keyboardType: TextInputType.number,
        maxLength: 1,

        focusNode: pinCurrentFocus,
        style: TextStyles.textStyleForm(context),
        textAlign: TextAlign.center,
        decoration:  InputDecoration(
          // labelText: 'Pin 1',
          hintText: "*",
          counterText: "",
         border: OutlineInputBorder(
           borderSide: BorderSide(width: 1,color: primaryColor),
           borderRadius: BorderRadius.circular(DEFAULT_CORNER), // Adjust the radius as needed
         ),


        ),
        onChanged: (value) {
          if (value.length == 1) {
            pinNextFocuss.requestFocus();
          }
        },
        validator: (value) {
          if (value?.length == 0) {
            pinCurrentFocus.requestFocus();
            return getTextByKey(key: TranslationKey.keyEmptyField);
          }
        },
      ),
    );
  }
}
