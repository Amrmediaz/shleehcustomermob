import 'package:country_code_picker/country_code_picker.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/core/widgets/text_form/password_widget.dart';
import 'package:shleehcustomer/features/authentication/login/domain/entities/user_login.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/bloc/login/login_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/bloc/login/login_event.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/pages/send_otp_page.dart';
import 'package:shleehcustomer/features/authentication/reset_password/presentation/pages/reset_password_page.dart';
import '../../../../../../core/styles/text/text_style.dart';
import '../../../../../../core/util/biometric_auth.dart';
import '../../../../../../core/util/Constants.dart';
import '../../../../../../core/util/enums.dart';
import '../../../../../../core/util/cashed_data/cashed_file.dart';
import '../../../../../../core/util/text_function.dart';
import '../../../../../../core/widgets/app_bar_auth.dart';
import '../../../../../../core/widgets/text_form/text_form_field_widget.dart';
import '../../../../../home_page/presentation/pages/home_page.dart';
import '../../pages/biometric_login_page.dart';

class FormLoginWidget extends StatefulWidget {
  const FormLoginWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<FormLoginWidget> createState() => _FormLoginWidgetState();
}

class _FormLoginWidgetState extends State<FormLoginWidget> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _countryCodeSelected = DEFAULT_COUNTRY_CODE_NUM;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
                children: [
                  AppBarAuth(),
                  const SizedBox(
                    height: 60,
                  ),
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
                  //
                  const SizedBox(
                    height: 10,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ResetPasswordPage()),
                        );
                      },
                      child: Text(
                        getTextByKey(key: TranslationKey.keyResetPassword),
                        textAlign: TextAlign.left,
                        style: TextStyles.textStyleHelper(context)
                            .copyWith(color: appTextColor),
                      ),
                    ),
                  ]),
                  const SizedBox(
                    height: 10,
                  ),
                  ActionBtn(
                      btnColor: primaryColor,
                      onPressed: () {
                        validateFormThenUpdateOrAddPost();
                      },
                      btnTitle: TranslationKey.keyLogin),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildBiometricLoginButton(),
                  ActionBtn(
                      btnTxtColor: primaryColor,
                      borderColor: primaryColor,
                      btnColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      },
                      btnTitle: TranslationKey.keySkipLogin),

                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTextByKey(key: TranslationKey.keyNotRegister),
                        style: TextStyles.textStyleHelper(context)
                            .copyWith(color: appTextColor),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      GestureDetector(
                          child: Text(
                            getTextByKey(
                                key: TranslationKey.keyRegisterNewAccount),
                            style: TextStyles.textStyleButton(context).copyWith(
                                decoration: TextDecoration.underline,
                                color: primaryColor),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const SendOtpPage()),
                            );
                          })
                    ],
                  )
                ]),
          ),
        ));
  }

  /// Visible "login with fingerprint" retry button — covers the case where
  /// the splash screen's own biometric attempt (see launch_screen.dart)
  /// was cancelled/failed and fell back to this page, or the guest just
  /// backgrounded/reopened the app without going through the splash at
  /// all. Only shown when there's actually something to unlock: biometric
  /// login is enabled AND a session is still saved (CasheFile.isLogin) —
  /// a guest who explicitly logged out has no session left for a
  /// fingerprint to unlock, so the button correctly disappears after
  /// logout.
  Widget _buildBiometricLoginButton() {
    return FutureBuilder<bool>(
      future: _canUseBiometricLogin(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return Column(
          children: [
            ActionBtn(
              btnTxtColor: primaryColor,
              borderColor: primaryColor,
              btnColor: Colors.white,
              onPressed: () => _loginWithBiometric(context),
              btnTitle: TranslationKey.keyLoginWithBiometric,
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Future<bool> _canUseBiometricLogin() async {
    final enabled = await BiometricPrefs.isEnabled();
    if (!enabled) return false;
    final available = await BiometricAuthService.isAvailable();
    if (!available) return false;
    return CasheFile().isLogin();
  }

  void _loginWithBiometric(BuildContext context) {
    // Opens the dedicated biometric-login page (with its own retry and
    // "use password instead" fallback) rather than firing the native
    // prompt directly from this button's tap.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BiometricLoginPage()),
    );
  }

  void validateFormThenUpdateOrAddPost() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      var comletePhone =
          _countryCodeSelected.replaceAll("+", "") + _usernameController.text;
      BlocProvider.of<LoginBloc>(context).add(LoginUserEvent(
          {"username": comletePhone, "password": _passwordController.text},
          true));
    }
  }
}
