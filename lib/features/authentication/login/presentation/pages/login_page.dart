import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/widgets/login_page/form_widget.dart';
import 'package:shleehcustomer/features/home_page/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/snackbar_message.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      // appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }


  Widget _buildBody() {
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is MessageLoginState) {
                if (state.isMainLogin) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false);
                }
              } else if (state is ErrorLoginState) {
                if (state.isMainLogin) {
                  SnackBarMessage().showErrorSnackBar(
                      message: state.message, context: context);
                  CommonFunctions.showBottomDialog(
                      context,
                      Icon(
                        Icons.error,
                        color: primaryColor,
                        size: CommonFunctions.calculateIconSize(context),
                      ),
                      state.message,
                      "");
                }
              }
            },
            builder: (context, state) {
              if (state is LoadingLoginState || state is MessageLoginState) {
                return const LoadingWidget();
              } else
                {
                  return const FormLoginWidget();

                }

            },
          )),
    );
  }
}
