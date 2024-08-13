import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/bloc/login/login_event.dart';

import '../../features/authentication/login/presentation/bloc/login/login_bloc.dart';
import '../strings/language.dart';
import '../styles/text/text_style.dart';
import '../widgets/text_form/password_widget.dart';
import '../widgets/text_form/text_form_field_widget.dart';
import 'Constants.dart';
import 'enums.dart';

class BottomSheetsCustom {
  static void showFailBottomWidgetDialog(BuildContext context, String title, String message,) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyles.textStyleTitle(context),
          ),
          content: Row(
            children: <Widget>[
              Icon(
                Icons.error,
                color: primaryColor,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyles.textStyleBody(context)),
                ),

            ],
          ),

        );
      },
    );
  }
  static void showSuccessBottomWidgetDialog(BuildContext context, String title, String message,) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyles.textStyleTitle(context),
          ),
          content: Row(
            children: <Widget>[
              Icon(
                Icons.check_circle_outlined,
                color: primaryColor,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                    message,
                    style: TextStyles.textStyleBody(context)),
              ),

            ],
          ),

        );
      },
    );
  }


  static  showLoginBottomDialog(BuildContext context) {
    TextEditingController _usernameController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    String _countryCodeSelected = DEFAULT_COUNTRY_CODE_NUM;

    showModalBottomSheet(
      isScrollControlled: true,


      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DEFAULT_CORNER)),
      ),
      context: context,

      builder: (BuildContext context) {

        return SizedBox(
            height: MediaQuery.of(context).copyWith().size.height * (3 / 4),child:  Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                getTextByKey(key: TranslationKey.keyLoginDes),
                style: TextStyles.textStyleHeadline(context)
                    .copyWith(color: primaryColor),
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      decoration: BoxDecoration(
                          color: formGreyColor,
                          borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                      child: CountryCodePicker(
                        onChanged: (value) {
                          _countryCodeSelected =
                              value.code ?? DEFAULT_COUNTRY_CODE_NUM;
                        },
                        initialSelection: 'OM',
                        favorite: const [
                          DEFAULT_COUNTRY_CODE,
                          DEFAULT_COUNTRY_CODE
                        ],
                        showCountryOnly: true,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        showFlag: false,
                        flagWidth: 20.0,
                        searchStyle: TextStyles.textStyleForm(context),
                        textStyle:
                        TextStyles.textStyleForm(context).copyWith(),
                      ),
                    ),
                    Expanded(
                      child: TextFormFieldWidget(
                          name: getTextByKey(
                              key: TranslationKey.keyPhoneNumber),
                          textInputType: TextInputType.number,
                          maxLength: MAX_LENGTH_TEXT_PHONE,
                          textInputFormatter:
                          TextFormat.phoneFormat.formatter,
                          multiLines: false,
                          controller: _usernameController),
                    )
                  ]),
              PasswordTextFieldWidget(
                obscureText: true,
                passwordController: _passwordController,
                helperTxt: "",
              ),
              ActionBtn(onPressed: (){
                var comletePhone =
                    _countryCodeSelected.replaceAll("+", "") + _usernameController.text;
                BlocProvider.of<LoginBloc>(context)
                    .add(LoginUserEvent(
                    {"username" : comletePhone , "password":_passwordController.text},false));

              }, btnTitle: getTextByKey(key: TranslationKey.keyLogin), btnColor: primaryColor)
            ],
          ),
        ));
      },
    );
  }
}
