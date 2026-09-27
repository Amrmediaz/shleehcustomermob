import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/bloc/register/register_user_bloc.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/pages/register_user_page.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/widgets/otp_pages/otp_verify_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/snackbar_message.dart';
import '../../../../../core/widgets/loading_widget.dart';
class VerifyOtpPage extends StatefulWidget {
  final String phoneNumber;
  const VerifyOtpPage({required this.phoneNumber});
  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //  appBar: _buildAppbar(),
      body: _buildBody(widget.phoneNumber)
    );
  }
}



  Widget _buildBody(String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.all(10),
            child: BlocConsumer<RegisterBloc, RegisterUserState>(
              listener: (context, state) {
                if (state is MessageVerifyOtpState) {
                  // SnackBarMessage().showSuccessSnackBar(
                  //     message: state.message, context: context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          (RegisterUserPage(phoneNumber: phone))));
                } else if (state is ErrorVerifyOtpUserState) {
                  print("sadasdasdas");
                  CommonFunctions.showBottomDialog(
                      context,
                    icon:  Icon(
                        Icons.sms_failed,
                        size: CommonFunctions.calculateIconSize(context),
                        color: primaryColor,
                      ),
                   title:    state.message,
                   description:    getTextByKey(key: TranslationKey.keyShouldOTPMatch));
                }
              },
              builder: (context, state) {
                if (state is LoadingRegisterUserState) {
                  return const LoadingWidget();
                }

                return FormVerifyOtpWidget(phone: phone);
              },
            )),
      ],
    );
  }

