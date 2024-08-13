import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/core/widgets/bottom_sheets.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/pages/login_page.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/pages/register_user_page.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:shleehcustomer/features/booking/presentation/pages/user_booking_screen.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalets_page.dart';
import 'package:shleehcustomer/features/home_page/presentation/bloc/home/home_bloc.dart';
import 'package:shleehcustomer/features/settings/presentation/pages/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../../../../core/util/Constants.dart';
import '../../../../core/widgets/app_bar_back.dart';
import '../../../authentication/login/presentation/bloc/login/login_bloc.dart';
import '../widgets/bottom_nav_bar.dart';

PersistentTabController _controller = PersistentTabController(initialIndex: 0);
var casheFile = CasheFile();

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: _buildAppbar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      if (state is hideBottomBarState) {
        return SafeArea(top: !state.isHidden, child: bottomBar(context, true));
      }

      return SafeArea(top: true, child: bottomBar(context, false));
    });
  }

  Widget bottomBar(BuildContext context, bool isHiddenBottom) {
    return Column(children: [
      // SizedBox(
      //   height: CommonFunctions.getSafeAreaTip(context),
      // ),
      Visibility(
          visible: !isHiddenBottom,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(DEFAULT_CORNER),
                    bottomRight: Radius.circular(DEFAULT_CORNER))),
            child: AppBarBack(
                // hasEndIcon: true,
                isMain: false,
                leadingWidgetAction: () {
              Navigator.pop(context);
            }),
          )),
      Expanded(
        child: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(context),

          confineInSafeArea: false,

          hideNavigationBar: isHiddenBottom,
          backgroundColor: Colors.white, // Default is Colors.white.
          handleAndroidBackButtonPress: true, // Default is true.
          resizeToAvoidBottomInset:
              true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
          stateManagement: true, // Default is true.
          hideNavigationBarWhenKeyboardShows:
              true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Colors.white,
          ),
          popAllScreensOnTapOfSelectedTab: false,
          popActionScreens: PopActionScreensType.all,
          popAllScreensOnTapAnyTabs: false,
          itemAnimationProperties: const ItemAnimationProperties(
            // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: const ScreenTransitionAnimation(
            // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle.style1,
          onItemSelected: (index) async {
            CasheFile.staticValue = true;
            if (index == 0) {
              CommonFunctions.pageNumberChalets = 1;
              BlocProvider.of<ChaletsBloc>(context).add(GetAllChaletsEvent(
                  pageNumber: CommonFunctions.pageNumberChalets,
                  body: const {
                    "page": 1,
                    "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
                    "heightolow": 1,
                    "rateheightolow": 0
                  }));
            } else if (index == 1 && CasheFile.isLoginUser) {
              var expireDate = await casheFile.getUserTokenExpireDate();

              if (isTokenExpired(expireDate)) {
                if (context.mounted) {
                  _controller.jumpToTab(0);
                  await expireToken(context);
                }
              } else {
                CommonFunctions.pageNumberBookings = 1;
                if (context.mounted) {
                  BlocProvider.of<BookingsBloc>(context)
                      .add(GetAllBookingsEvent(pageNumber: 1, pageSize: 10));
                }
              }
            } else if (index == 1 && !CasheFile.isLoginUser) {
              CommonFunctions.showBottomWidgetDialog(
                  context,
                  Icon(
                    Icons.person_pin,
                    color: primaryColor,
                  ),
                  Column(
                    children: [
                      Text(
                        getTextByKey(key: TranslationKey.keyShouldLogin),
                        style: TextStyles.textStyleTitle(context),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ActionBtn(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const LoginPage();
                                },
                              ),
                                  (_) => false,
                            );
                          },
                          btnTitle: getTextByKey(key: TranslationKey.keyLogin),
                          btnColor: primaryColor)
                    ],
                  ));
              _controller.jumpToTab(0);
            } else if (index == 2 && CasheFile.isLoginUser) {
              var expireDate = await casheFile.getUserTokenExpireDate();

              if (isTokenExpired(expireDate)) {
                if (context.mounted) {
                  _controller.jumpToTab(0);
                  await expireToken(context);
                }
              }
            }
          }, // Choose the nav bar style with this property.
        ),
      ),
    ]);
  }

  List<Widget> _buildScreens() {
    return [
      ChaletsPage(),
      UserBookingPage(),
      SettingPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    var bottomNavBar = BottomNavBar();
    return [
      bottomNavBar.getNavBar(
          title: getTextByKey(key: TranslationKey.keyChalets),
          icon: const Icon(CupertinoIcons.house_fill),
          buildContext: context),
      bottomNavBar.getNavBar(
          title: getTextByKey(key: TranslationKey.keyMyBookings),
          icon: const Icon(CupertinoIcons.calendar_circle),
          buildContext: context),
      bottomNavBar.getNavBar(
          title: getTextByKey(key: TranslationKey.keySettings),
          icon: const Icon(Icons.settings),
          buildContext: context),
    ];
  }
}
