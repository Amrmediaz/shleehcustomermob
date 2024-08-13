import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/bloc/register/register_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/util/enums.dart';
import '../../../../../../core/util/text_function.dart';
import '../../../../../../core/widgets/action_btn.dart';
import '../../../../../../core/widgets/app_bar_back.dart';
import '../../../../../../core/widgets/text_form/otp/otp_pin_form.dart';
import '../../../../../../core/widgets/text_form/text_form_field_widget.dart';

class FormVerifyOtpWidget extends StatefulWidget {
  final String phone;
  FormVerifyOtpWidget({required this.phone});

  @override
  State<FormVerifyOtpWidget> createState() => _FormVerifyOtpWidgetState();
}

class _FormVerifyOtpWidgetState extends State<FormVerifyOtpWidget> {
  final _formKey = GlobalKey<FormState>();
  String pin = "";
  var otpController = TextEditingController();

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
                  Text(
                    getTextByKey(key: TranslationKey.keyEnterOtp),
                    style: TextStyles.textStyleHelper(context),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormFieldWidget(
                    controller: otpController,
                    textInputFormatter:
                    TextFormat.phoneFormat.formatter,
                    textInputType: TextInputType.number,
                    multiLines: false,
                    name: getTextByKey(key: TranslationKey.keyOTP),
                    maxLength: 4,
                  ),

                  // PinForm(
                  //   onSubmit: (String pinEntered) {
                  //     pin = pinEntered;
                  //   },
                  // ),
                  const SizedBox(
                    height: 30,
                  ),
                  ActionBtn(
                    btnColor: primaryColor,
                    onPressed: validateFormThenVerifyOtp,
                    btnTitle: getTextByKey(key: TranslationKey.keyVerifyOtp),
                  )
                ]),
          ),
        ));
  }

  void validateFormThenVerifyOtp() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      BlocProvider.of<RegisterBloc>(context).add(OtpVerifyEvent(
          otpCode: otpController.text, phoneNumber: widget.phone));
    }
  }
}
// Text("${getTextByKey(key:TranslationKey.keyPhoneNumber)} ${widget.phone}",style: TextStyles.textStyleBody(context),),
// const SizedBox(height: 15),
// PinForm(onSubmit: (String pinEntered) {
// pin = pinEntered;
// },),
// const SizedBox(height: 30,),
// ActionBtn(btnColor: primaryColor,onPressed: validateFormThenUpdateOrAddPost,btnTitle: getTextByKey(key:TranslationKey.keyVerifyOtp),)
