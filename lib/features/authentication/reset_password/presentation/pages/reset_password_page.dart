import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/pages/login_page.dart';
import 'package:shleehcustomer/features/authentication/reset_password/presentation/bloc/reset/reset_password_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/util/snackbar_message.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../widgets/reset_password_page/form_reset_widget.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //  appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(title: Text("Reset Password Page"));
  }

  Widget _buildBody() {
    return Center(
      child: Padding(
          padding: EdgeInsets.all(10),
          child: BlocConsumer<ResetBloc, ResetPasswordState>(
            listener: (context, state) async {

              if (state is MessageResetPasswordState) {
                await CommonFunctions.showBottomDialog(
                    context,
                 icon:    Icon(Icons.check_circle,
                        color: Colors.green, size: CommonFunctions.calculateIconSize(context)),
                  title:   getTextByKey(
                        key: TranslationKey.keyResetPasswordSuccessMessage),
                   description:  "");
                await CommonFunctions.delay(() {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false);
                }, seconds: 5);
              } else if (state is ErrorResetPasswordState) {
               // SnackBarMessage().showErrorSnackBar(
                   // message: state.message, context: context);
                await CommonFunctions.showBottomDialog(
                    context,
                 icon:    Icon(Icons.error,
                        color: Colors.red, size: CommonFunctions.calculateIconSize(context)),
                  title:   getTextByKey(
                        key: TranslationKey.keyResetPasswordFailedMessage),
                  description:   "");
              }
            },
            builder: (context, state) {
              if (state is LoadingResetPasswordState) {
                return LoadingWidget();
              }

              return FormResetWidget();
            },
          )),
    );
  }
}
