import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/widgets/login_page/form_widget.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/bloc/register/register_user_bloc.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/pages/verify_otp_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/cashed_data/cashed_file.dart';
import '../../../../../core/util/snackbar_message.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../widgets/otp_pages/otp_mobile_form.dart';

class SendOtpPage extends StatelessWidget {
  const SendOtpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //  appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(title: Text(getTextByKey(key: TranslationKey.keySendOtp)));
  }

  Widget _buildBody() {
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: BlocConsumer<RegisterBloc, RegisterUserState>(
            listener: (context, state) async {
              var phone = await CasheFile().getPhoneForRegisterTemp();
              if (state is MessageCheckUserExistState) {

                BlocProvider.of<RegisterBloc>(context)
                    .add(OtpSendEvent(phoneNumber: phone));
              } else if (state is ErrorCheckExistedUserState) {

                CommonFunctions.showBottomDialog(
                    context,
                    Icon(
                      Icons.person_pin,
                      color: primaryColor,
                      size: CommonFunctions.calculateIconSize(context),
                    ),
                    getTextByKey(key: TranslationKey.keyExistUser),
                    getTextByKey(key: TranslationKey.keyLoginExistUser));
              } else if (state is MessageSendOtpState) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => (VerifyOtpPage(
                          phoneNumber: phone,
                        ))));
              }
            },
            builder: (context, state) {
              if (state is LoadingRegisterUserState ) {
                return const LoadingWidget();
              }
              return const FormOtpWidget();
            },
          )),
    );
  }

  Future<String> getPhoneLocal() async {
    return await CasheFile().getPhoneForRegisterTemp();
  }
}
