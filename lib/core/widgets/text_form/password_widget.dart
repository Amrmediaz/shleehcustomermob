import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:flutter/material.dart';

import '../../strings/language.dart';
import '../../styles/app_theme.dart';
import '../../util/Constants.dart';

class PasswordTextFieldWidget extends StatefulWidget {
  final bool obscureText;
  final TextEditingController passwordController;
  final String? helperTxt;
  final String? labelTxt;

  // this used for validate password when register user and avoid validate in login page
  final bool? allValidations;
  const PasswordTextFieldWidget({
    required this.obscureText,
    required this.passwordController,
     this.helperTxt,
    this.allValidations,
    this.labelTxt
  });

  @override
  _PasswordTextFieldWidgetState createState() =>
      _PasswordTextFieldWidgetState();
}

class _PasswordTextFieldWidgetState extends State<PasswordTextFieldWidget> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
      return Padding (padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscureText,

            style: TextStyles.textStyleForm(context),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(borderSide:BorderSide(color: primaryColor,width: 0.9),borderRadius:BorderRadius.circular(DEFAULT_CORNER)  ),

              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
              ),
              fillColor: formGreyColor,
              filled: true,
              errorStyle:TextStyles.textStyleHelper(context).copyWith(color: primaryColor) ,
              labelStyle: TextStyles.textStyleForm(context),
              helperStyle: TextStyles.textStyleHelper(context),
              hintStyle:TextStyles.textStyleHint(context,isObscure: true) ,
              labelText: widget.labelTxt ?? getTextByKey(key:TranslationKey.keyEnterPassword),helperText: widget.helperTxt != "" ? getTextByKey(key: TranslationKey.keyPasswordRules) : null ,helperMaxLines: widget.helperTxt  != "" ? 2 : 1,
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
            ),
            validator: (value) {

              if (value == null || value.isEmpty ) {
                return getTextByKey(key: TranslationKey.keyRequiredPassword);
              }
              if (value.length < 6 && widget.helperTxt == null) {
                return getTextByKey(key: TranslationKey.keyPasswordLength);
              }

              if (!value.contains(RegExp(r'[A-Z]'))&& widget.allValidations != null) {
                return getTextByKey(key: TranslationKey.keyPasswordUpperCase);
              }

              if (!value.contains(RegExp(r'[a-z]'))&& widget.allValidations != null) {
                return getTextByKey(key: TranslationKey.keyPasswordLowerCase);

              }

              if (!value.contains(RegExp(r'[0-9]'))&& widget.allValidations != null) {
                return getTextByKey(key: TranslationKey.keyPasswordDigit);

              }

              if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')) && widget.allValidations != null) {
                return getTextByKey(key: TranslationKey.keyPasswordSpecialCharacter);

              }
              return null;
            },
          ),
          const SizedBox(height: 1.0),
        ],
      ),
      );

  }
}

