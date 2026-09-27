
import 'package:country_code_picker/country_code_picker.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/core/util/text_function.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/bloc/register/register_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/util/Constants.dart';
import '../../../../../../core/util/common_functions.dart';
import '../../../../../../core/util/enums.dart';
import '../../../../../../core/widgets/action_btn.dart';
import '../../../../../../core/widgets/app_bar_back.dart';
import '../../../../../../core/widgets/text_form/text_form_field_widget.dart';


class FormOtpWidget extends StatefulWidget {
  const   FormOtpWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<FormOtpWidget> createState() => _FormOtpWidgetState();
}

class _FormOtpWidgetState extends State<FormOtpWidget> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _phoneController = TextEditingController();
  String _countryCodeSelected = DEFAULT_COUNTRY_CODE_NUM;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
                    height: 30,
                  ),
                  Text(
                    getTextByKey(key: TranslationKey.keyCreateNewAccount),
                    style: TextStyles.textStyleHeadline(context)
                        .copyWith(color: primaryColor),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(getTextByKey(key: TranslationKey.keyEnterYourPhone),style: TextStyles.textStyleHelper(context),),
                  const SizedBox(
                    height: 10,
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
                                  value.dialCode ?? DEFAULT_COUNTRY_CODE_NUM;
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



                  BlocBuilder<RegisterBloc, RegisterUserState>(
                    builder: (context, state) {
                      return ActionBtn(
                          isLoading: state is LoadingRegisterUserState,
                          btnColor: primaryColor,
                          onPressed: () {
                            validateFormThenSendOTP();
                          },
                          btnTitle: TranslationKey.keySendOtp);
                    },
                  ),
                ]),
          ),
        ));
  }

  void validateFormThenSendOTP() async {
    final isValid = _formKey.currentState!.validate();
    var phone = _countryCodeSelected.replaceAll("+", "") + CommonFunctions.arabicToEnglish(_phoneController.text);
    await CasheFile().savePhoneForRegisterTemp(phone);
    if (isValid) {
      BlocProvider.of<RegisterBloc>(context).add(CheckUserExistEvent(
          phoneNumber:phone));

    }
  }
}
