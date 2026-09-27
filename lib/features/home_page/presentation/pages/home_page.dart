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
import 'package:shleehcustomer/features/buildings/presentation/bloc/Buildings/buildings_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalets_page.dart';
import 'package:shleehcustomer/features/home_page/presentation/bloc/home/home_bloc.dart';
import 'package:shleehcustomer/features/settings/presentation/pages/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../core/util/Constants.dart';
import '../../../../core/widgets/app_bar_back.dart';
import '../../../authentication/login/presentation/bloc/login/login_bloc.dart';
import '../../../booking/presentation/widgets/payment/PaymentRedirectListener.dart';
import '../../../buildings/presentation/pages/buildings_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ── State Management ───────────────────────────────────────────────────────
  late PersistentTabController _tabController;
  late final CasheFile _cacheFile;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _tabController = PersistentTabController(initialIndex: 0);
    _cacheFile = CasheFile();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Wrap entire HomePage with Directionality for RTL
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Status bar now sits on top of the purple bar (see _buildBottomNavBar
      // below, which paints purple all the way up behind the notch), so the
      // clock/battery/wifi glyphs need to switch to light/white to stay
      // readable — they were dark-on-white before, which is invisible on
      // purple.
      value: SystemUiOverlayStyle.light,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child:  PaymentRedirectListener(child: Scaffold(
          body: _buildBody(context),
        ),
      )),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final isHiddenBottom = state is hideBottomBarState && state.isHidden;
        // Top inset is now handled manually inside the purple bar itself
        // (see _buildBottomNavBar) so its color can extend behind the
        // status bar/notch instead of leaving a white gap above it —
        // SafeArea's top padding would otherwise reserve that space with
        // the plain Scaffold background before the purple bar even starts.
        return SafeArea(
          top: false,
          child: _buildBottomNavBar(context, isHiddenBottom),
        );
      },
    );
  }

  // ── Bottom Navigation Bar ──────────────────────────────────────────────────
  Widget _buildBottomNavBar(BuildContext context, bool isHiddenBottom) {
    return Column(
      children: [
        // ✅ AppBar (only when not hidden)
        Visibility(
          visible: !isHiddenBottom,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              15,
              // Push the actual bar content (logo/icon) below the notch —
              // the purple background above still paints all the way to
              // the very top of the screen, only the content is inset.
              MediaQuery.of(context).padding.top,
              15,
              0,
            ),
            // Flat solid purple, no rounded bottom corners and no shadow of
            // its own — the Chalets tab's hero header (chalet_page_widget's
            // _buildColoredHeroHeader) sits flush underneath this and owns
            // the rounded-bottom + shadow for the *combined* block. Giving
            // both a radius/shadow here too was creating a visible white
            // seam between two separate rounded shapes instead of one
            // continuous purple band.
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: AppBarBack(
              isMain: false,
              leadingWidgetAction: () {
                if (mounted) Navigator.pop(context);
              },
            ),
          ),
        ),

        // ✅ Tab View
        Expanded(
          child: PersistentTabView(
            context,
            controller: _tabController,
            screens: _buildScreens(),
            items: _navBarsItems(context),
            backgroundColor: Colors.white,
            handleAndroidBackButtonPress: true,
            resizeToAvoidBottomInset: true,
            stateManagement: false,
            decoration: NavBarDecoration(
              borderRadius: BorderRadius.circular(10.0),
              colorBehindNavBar: Colors.white,
            ),
            // ✅ تحديث البيانات عند التبديل بين الـ tabs
            onItemSelected: (index) => _onTabSelected(context, index),
            // ✅ إعادة بناء الـ screens عند الحاجة
            navBarStyle: NavBarStyle.style4 ,
          ),
        ),
      ],
    );
  }

  // ── Tab Selection Logic ────────────────────────────────────────────────────
  // Tab order: 0 Chalets, 1 Buildings, 2 Favorites, 3 My Bookings, 4 Settings.
  Future<void> _onTabSelected(BuildContext context, int index) async {
    if (_isDisposed || !mounted) return;

    CasheFile.staticValue = true;

    switch (index) {
      case 0:
        break;
      case 1:
        // FIX: this used to just construct a GetAllBuildingsEvent and drop
        // it on the floor (never added to the bloc), with no `break` before
        // falling into case 2 — a switch case in Dart isn't allowed to fall
        // through into the next case unless it's empty, so this was a
        // compile error blocking the whole app from building. Now actually
        // dispatches the refresh and returns, same pattern as _loadChalets.
        _loadBuildings(context);
        break;
      case 2:
        // Favorites tab — data already lives in FavoritesCubit's in-memory
        // state (loaded once at app start from local storage), nothing to
        // fetch here.
        break;
      case 3:
        await _loadBookings(context);
        break;
      case 4:
        await _checkTokenExpiry(context, index);
        break;
    }
  }

  // ── Load Buildings ─────────────────────────────────────────────────────────
  void _loadBuildings(BuildContext context) {
    CommonFunctions.pageNumberbuildings = 1;

    if (mounted) {
      BlocProvider.of<BuildingsBloc>(context).add(
        GetAllBuildingsEvent(
          pageNumber: CommonFunctions.pageNumberbuildings,
          body: const {
            "page": 1,
            "pageSize": PAGE_SIZE_BUILDINGS_PAGINATION,
            "heightolow": 1,
            "rateheightolow": 0,
          },
        ),
      );
    }
  }

  // ── Load Chalets ───────────────────────────────────────────────────────────
  void _loadChalets(BuildContext context) {
    // ✅ Reset page number to 1 when returning to buildings tab
    CommonFunctions.pageNumberChalets = 1;

    if (mounted) {
      BlocProvider.of<ChaletsBloc>(context).add(
        GetAllChaletsEvent(
          pageNumber: CommonFunctions.pageNumberChalets,
          body: const {
            "page": 1,
            "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
            "heightolow": 1,
            "rateheightolow": 0,
          },
        ),
      );
    }
  }

  // ── Load Bookings ──────────────────────────────────────────────────────────
  Future<void> _loadBookings(BuildContext context) async {
    if (!CasheFile.isLoginUser) {
      _showLoginDialog(context);
      return;
    }

    // ✅ Check token expiry
    final expireDate = await _cacheFile.getUserTokenExpireDate();

    if (!mounted || _isDisposed) return;

    if (isTokenExpired(expireDate)) {
      _tabController.jumpToTab(0);
      await _showTokenExpiredDialog(context);
      return;
    }

    // ✅ Load bookings
    CommonFunctions.pageNumberBookings = 1;
    if (mounted) {
      BlocProvider.of<BookingsBloc>(context)
          .add(GetAllBookingsEvent(pageNumber: 1, pageSize: 10));
      BlocProvider.of<BookingsBloc>(context)
          .add(GetAllBookingsEventFlat(pageNumber: 1, pageSize: 10));
    }
  }

  // ── Check Token Expiry for Settings ────────────────────────────────────────
  Future<void> _checkTokenExpiry(BuildContext context, int tabIndex) async {
    if (!CasheFile.isLoginUser) return;

    final expireDate = await _cacheFile.getUserTokenExpireDate();

    if (!mounted || _isDisposed) return;

    if (isTokenExpired(expireDate)) {
      _tabController.jumpToTab(0);
      await _showTokenExpiredDialog(context);
    }
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  /// Show login required dialog
  void _showLoginDialog(BuildContext context) {
    CommonFunctions.showBottomWidgetDialog(
      context,
      Icon(
        Icons.person_pin,
        color: primaryColor,
        size: 48,
      ),
      // ✅ Wrap dialog content with Directionality
      Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text(
              getTextByKey(key: TranslationKey.keyShouldLogin),
              style: TextStyles.textStyleTitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ActionBtn(
              onPressed: () {
                // ✅ Dismiss dialog first
                Navigator.of(context).pop();

                // ✅ Navigate to login
                if (mounted) {
                  Navigator.of(context, rootNavigator: true)
                      .pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const LoginPage(),
                    ),
                        (_) => false,
                  );
                }
              },
              btnTitle: getTextByKey(key: TranslationKey.keyLogin),
              btnColor: primaryColor,
            ),
          ],
        ),
      ),
    );

    // ✅ Reset tab to home
    _tabController.jumpToTab(0);
  }

  /// Show token expired dialog
  Future<void> _showTokenExpiredDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => Directionality(
        // ✅ Wrap dialog with Directionality
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('انتهت الجلسة'),
          content: const Text('انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                if (mounted) {
                  Navigator.of(context, rootNavigator: true)
                      .pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const LoginPage(),
                    ),
                        (_) => false,
                  );
                }
              },
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Screens ────────────────────────────────────────────────────────────────
  List<Widget> _buildScreens() {
    return [
      const ChaletsPage(),
      const BuildingsPage(),
      const FavoritesPage(),
      UserBookingPage(),
      SettingPage(),
    ];
  }

  // ── Navigation Items ───────────────────────────────────────────────────────
  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    final bottomNavBar = BottomNavBar();
    return [
      bottomNavBar.getNavBar(
        title: getTextByKey(key: TranslationKey.keyChalets),
        icon: const Icon(CupertinoIcons.house_alt),
        buildContext: context,
      ),
      bottomNavBar.getNavBar(
        title: "الشقق",
        icon: const Icon(CupertinoIcons.building_2_fill),
        buildContext: context,
      ),
      bottomNavBar.getNavBar(
        title: "المفضلة",
        icon: const Icon(CupertinoIcons.heart),
        buildContext: context,
      ),
      bottomNavBar.getNavBar(
        title: getTextByKey(key: TranslationKey.keyMyBookings),
        icon: const Icon(CupertinoIcons.calendar_circle),
        buildContext: context,
      ),
      bottomNavBar.getNavBar(
        title: getTextByKey(key: TranslationKey.keySettings),
        icon: const Icon(Icons.settings),
        buildContext: context,
      ),

    ];
  }
}