import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/core/widgets/app_bar_back.dart';
import 'package:shleehcustomer/features/authentication/reset_password/presentation/bloc/reset/reset_password_bloc.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/styles/text/text_style.dart';
import '../../../../../../core/util/Constants.dart';
import '../../../../../../core/util/enums.dart';
import '../../../../../../core/util/text_function.dart';
import '../../../../../../core/widgets/text_form/text_form_field_widget.dart';

class FormResetWidget extends StatefulWidget {
  const FormResetWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<FormResetWidget> createState() => _FormResetWidgetState();
}

class _FormResetWidgetState extends State<FormResetWidget> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _phoneController = TextEditingController();
  String _countryCodeSelected = DEFAULT_COUNTRY_CODE_NUM;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   AppBarBack(leadingWidgetAction: () {
                    Navigator.pop(context);
                  }),
                  const SizedBox(
                    height: 60,
                  ),
                  Text(
                    getTextByKey(key: TranslationKey.keyResetDes),
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
                              controller: _phoneController),
                        )
                      ]),

                  //
                  const SizedBox(
                    height: 10,
                  ),
                  Text(getTextByKey(key: TranslationKey.keyResetGuide),style: TextStyles.textStyleHelper(context),),
                  const SizedBox(
                    height: 10,
                  ),


                  ActionBtn(
                      btnColor: primaryColor,
                      onPressed: () {
                        validateFormThenResetPassword();
                      },
                      btnTitle: TranslationKey.keyResetPassword),
                ]),
          ),
        ));
  }

  void validateFormThenResetPassword() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      BlocProvider.of<ResetBloc>(context).add(ResetPasEvent(
          phoneNumber: "${_countryCodeSelected.replaceAll("+", "")}${_phoneController.text}@gmail.com"));
    }
  }
}
