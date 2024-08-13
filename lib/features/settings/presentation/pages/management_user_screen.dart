import 'package:shleehcustomer/core/strings/language.dart';

import 'package:shleehcustomer/core/widgets/message_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/features/settings/presentation/widgets/management_user_widget/management_user_widget.dart';
import '../../../../../core/util/snackbar_message.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../bloc/setting/setting_bloc.dart';

class ManagementUserPage extends StatelessWidget {
  final String phoneNumber;
  const ManagementUserPage({required this.phoneNumber});

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
        child: BlocConsumer<SettingBloc, SettingState>(
          listener: (context, state) async {

          },
          builder: (context, state) {
            // Wrap your existing content with a Stack
            if (state is LoadingUserDataState){
              return const LoadingWidget();
            }else if (state is LoadedUserState){
            return Column(
              children: [
                // Your main content
                Expanded(
                  child: ManagementUserFormWidget(
                     user: state.user,),
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
          } else {
              return MessageDisplayWidget(message: getTextByKey(key: TranslationKey.keyError));
            }
    },
            buildWhen: (previous, current) {
              if (current is LoadedUserState ||
                  current is ErrorGetUserState) {
                return true;
              } else {
                return false;
              }
            }
          // buildWhen: (previous, current) =>
          // current is LoadingRegisterUserState,
        ),
      ),
    );
  }
}
