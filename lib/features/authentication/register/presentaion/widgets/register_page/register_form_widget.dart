import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/authentication/register/domain/entities/UserRegister.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/bloc/register/register_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/styles/text/text_style.dart';
import '../../../../../../core/util/Constants.dart';
import '../../../../../../core/util/snackbar_message.dart';
import '../../../../../../core/widgets/app_bar_back.dart';
import '../../../../../../core/widgets/text_form/password_widget.dart';
import '../../../../../../core/widgets/text_form/text_form_field_widget.dart';

class RegisterFormWidget extends StatefulWidget {
  final String phoneNumber;
  final bool isLoading;

  RegisterFormWidget({required this.phoneNumber,required this.isLoading});
  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordMatchController =
      TextEditingController();

  @override
  void initState() {
    _phoneController.text = widget.phoneNumber;
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _passwordMatchController.dispose();
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
                  Expanded(
                    child: ListView(children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            getTextByKey(
                                key: TranslationKey.keyCreateNewAccount),
                            style: TextStyles.textStyleHeadline(context)
                                .copyWith(color: primaryColor),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            getTextByKey(
                                key: TranslationKey.keyRequiredFillData),
                            style: TextStyles.textStyleHelper(context),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormFieldWidget(
                              name: getTextByKey(
                                  key: TranslationKey.keyPhoneNumber),
                              textInputType: TextInputType.name,
                              maxLength: MAX_LENGTH_TEXT_Name,isEnabled: false,
                              multiLines: false,
                              controller: _phoneController),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormFieldWidget(
                              name: getTextByKey(
                                  key: TranslationKey.keyFirstName),
                              textInputType: TextInputType.name,
                              maxLength: MAX_LENGTH_TEXT_Name,
                              multiLines: false,
                              controller: _firstNameController),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormFieldWidget(
                              name:
                                  getTextByKey(key: TranslationKey.keyLastName),
                              textInputType: TextInputType.text,
                              maxLength: MAX_LENGTH_TEXT_Name,
                              multiLines: false,
                              controller: _lastNameController),
                          const SizedBox(
                            height: 10,
                          ),
                          // TextFormFieldWidget(
                          //     name: getTextByKey(key: TranslationKey.keyEmail),
                          //     textInputType: TextInputType.emailAddress,
                          //     maxLength: MAX_LENGTH_TEXT_EMAIL,
                          //     multiLines: false,
                          //     // isEmail: true,
                          //     controller: _emailController),
                          const SizedBox(
                            height: 10,
                          ),
                          PasswordTextFieldWidget(
                            obscureText: true,
                            passwordController: _passwordController,
                            helperTxt: getTextByKey(
                                key: TranslationKey.keyPasswordRules),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          PasswordTextFieldWidget(
                            obscureText: true,
                            passwordController: _passwordMatchController,
                            helperTxt: "",
                            labelTxt: getTextByKey(
                                key: TranslationKey.keyPasswordMatch),
                          ),
                          const SizedBox(
                            height: 20,
                          ),



                              ActionBtn(isLoading: widget.isLoading,
                                btnColor: primaryColor,
                                onPressed: () {
                                  validateFormThenRegister();
                                },
                                btnTitle: TranslationKey.keyRegisterAccount),
                  ])
        ],
                      ),

                  )
                ]),
          ),
        ));
  }

  void validateFormThenRegister() {

    final isValid = _formKey.currentState!.validate();
    if (_passwordMatchController.text != _passwordController.text) {
      SnackBarMessage().showErrorSnackBar(
          message: getTextByKey(key: TranslationKey.keyPasswordNotMatch),
          context: context);
    } else if (isValid) {
      final userRegister = UserRegister(
          email: _phoneController.text + "@gmail.com",
          password: _passwordController.text,
          phone: _phoneController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text);
      BlocProvider.of<RegisterBloc>(context)
          .add(RegisterUseEvent(userRegister: userRegister));
    }
  }
}
