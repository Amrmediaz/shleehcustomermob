import 'package:shleehcustomer/core/strings/language.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../styles/app_theme.dart';
import '../../styles/text/text_style.dart';
import '../../util/Constants.dart';
import '../../util/text_function.dart';
import '../../util/validation/validation_text.dart';

class TextFormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool multiLines;
  final String name;
  final TextInputType? textInputType;
  final TextInputFormatter? textInputFormatter;
  final int? maxLength;
  final bool? isEnabled;
  final bool? isEmail;

  const TextFormFieldWidget({
    Key? key,
    this.textInputFormatter,
    this.maxLength,
    this.isEnabled,
    this.isEmail,
    this.textInputType,
    required this.controller,
    required this.multiLines,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: TextFormField(

          minLines: multiLines ? 6 : 1,
          enabled: isEnabled ?? true,
          maxLines: multiLines ? 6 : 1,
          maxLength: maxLength ?? MAX_LENGTH_TEXT_DEFAULT,
          style: TextStyles.textStyleForm(context),
          keyboardType: textInputType,
          inputFormatters: [
            textInputFormatter ?? FilteringTextInputFormatter.deny('')
          ],
          controller: controller,
          validator: (val) => isEmail != null
              ? ValidationText.validateEmail(val!)
              : val!.isEmpty
                  ? "$name ${getTextByKey(key: TranslationKey.keyEmptyOrShort)}"
                  : null,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(borderSide:BorderSide(color: primaryColor,width: 0.9),borderRadius:BorderRadius.circular(DEFAULT_CORNER)  ),
            //enabledBorder: OutlineInputBorder(borderSide:BorderSide(color: primaryColor,width: 0.1),borderRadius:BorderRadius.circular(DEFAULT_CORNER)  ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(DEFAULT_CORNER), // Adjust the radius as needed
              ),

              filled: true,
              fillColor: formGreyColor,
              hintText: getTextByKey(key: name),
              counterText: "",
              helperStyle: TextStyles.textStyleHelper(context),
              labelStyle: TextStyles.textStyleForm(context),
              errorStyle:TextStyles.textStyleHelper(context).copyWith(color: primaryColor) ,
              errorMaxLines: 2,
              labelText: name,
              hintStyle: TextStyles.textStyleHint(context)),
        ));
  }
}
