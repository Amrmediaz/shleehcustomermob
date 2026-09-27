import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/bloc/register/register_user_bloc.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/widgets/register_page/register_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/features/home_page/presentation/pages/home_page.dart';
import '../../../../../core/util/snackbar_message.dart';
import '../../../../../core/widgets/loading_widget.dart';

class RegisterUserPage extends StatelessWidget {
  final String phoneNumber;
  const RegisterUserPage({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
        title: Text(getTextByKey(key: TranslationKey.keyRegisterAccount)));
  }

  Widget _buildBody() {
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: BlocConsumer<RegisterBloc, RegisterUserState>(
            listener: (context, state)async {
              if (state is MessageRegisterUserState) {
                CommonFunctions.showBottomDialog(
                    context,
                   icon: Icon(
                      Icons.verified_user_sharp,
                      color: primaryColor,
                      size: CommonFunctions.calculateIconSize(context),
                    ),
                   title:  getTextByKey(key: TranslationKey.keySuccessRegisterTitle),
                 description:    getTextByKey(key: TranslationKey.keySuccessRegisterMsg));

                await CommonFunctions.delay(() {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false);
                }, seconds: 5);
              } else if (state is ErrorRegisterUserState) {
                SnackBarMessage().showErrorSnackBar(
                    message: state.message, context: context);
              }
            },
            builder: (context, state) {
              // Wrap your existing content with a Stack
              return Column(

                children: [
                  // Your main content
                  Expanded(
                    child: RegisterFormWidget(
                      phoneNumber: phoneNumber,
                      isLoading :state is LoadingRegisterUserState
                    ),
                  ),
                  // Loading indicator
                 // if (state is LoadingRegisterUserState)
                    // SizedBox(height: 50,
                    //   child: CircularProgressIndicator(
                    //     color: primaryColor,
                    //   ),
                    // ),
                ],
              );
            },
            // buildWhen: (previous, current) =>
            // current is LoadingRegisterUserState,
          ),
      ),
    );

  }
}
