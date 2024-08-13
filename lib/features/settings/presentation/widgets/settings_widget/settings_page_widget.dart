import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/bloc/login/login_event.dart';
import 'package:shleehcustomer/features/booking/domain/entities/booking.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalets_map_screen.dart';
import 'package:shleehcustomer/features/settings/presentation/pages/management_user_screen.dart';
import 'package:shleehcustomer/features/settings/presentation/pages/privacy_screen.dart';
import 'package:shleehcustomer/features/settings/presentation/widgets/settings_widget/setting_data_row.dart';

import '../../../../../core/strings/assets_path.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/app_bar_back.dart';
import '../../../../../core/widgets/text_icon.dart';
import '../../../../authentication/login/presentation/bloc/login/login_bloc.dart';
import '../../bloc/setting/setting_bloc.dart';

class SettingsPageWidget extends StatefulWidget {
  SettingsPageWidget({super.key});
  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: Container(
        padding: const EdgeInsets.all(5),
        color: Colors.grey.shade50,
        child: ListView(
          children: [
            Text(
              "  ${getTextByKey(key: TranslationKey.keySettings)}",
              style: TextStyles.textStyleHeadline(context),
            ),
            CasheFile.isLoginUser
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingDataRow(
                          onPressed: () {
                            BlocProvider.of<SettingBloc>(context)
                                .add(GetUserEvent());
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: const ManagementUserPage(
                                  phoneNumber: "phoneNumber"),
                              withNavBar: false,
                            );
                          },
                          text: getTextByKey(
                              key: TranslationKey.keyAccountManagement),
                          imagePath: AssetsPath.userImg),
                      const SizedBox(
                        height: 5,
                      ),
                      SettingDataRow(
                          onPressed: () async {
                            BlocProvider.of<LoginBloc>(context)
                                .add( UserLoginInitialEvent());

                            await CasheFile().setLogout(context);
                          },
                          text: getTextByKey(key: TranslationKey.keySignOut),
                          imagePath: AssetsPath.logoutImg),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        getTextByKey(key: TranslationKey.keySupport),
                        style: TextStyles.textStyleHeadline(context,
                            titleSizeFactor: 0.6),
                      ),
                    ],
                  )
                : Container(),
            SettingDataRow(
                onPressed: () {
                  CommonFunctions.showBottomWidgetDialog(
                      context,
                      Text(
                        getTextByKey(key: TranslationKey.keyContactWhatsApp),
                        style: TextStyles.textStyleBody(context),
                      ),
                      Column(
                        children: [
                          ActionBtn(
                              onPressed: () {
                                CommonFunctions.sendMessageToWhatsApp(
                                    "السلام عليكم \n عندي استفسار بخصوص  ");
                              },
                              btnTitle: getTextByKey(
                                  key: TranslationKey.keyContactSupport),
                              btnColor: primaryColor)
                        ],
                      ));
                },
                text: getTextByKey(key: TranslationKey.keyContactSupport),
                imagePath: AssetsPath.supportImg),
            const SizedBox(
              height: 10,
            ),
            SettingDataRow(
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const PrivacyScreen(),
                    withNavBar: false,
                  );
                },
                text: getTextByKey(key: TranslationKey.keyPrivacy),
                imagePath: AssetsPath.privacySvg),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ))
    ]);
  }
}
