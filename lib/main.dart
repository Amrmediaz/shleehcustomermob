import 'package:shleehcustomer/features/authentication/login/presentation/bloc/login/login_bloc.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/pages/login_page.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/bloc/register/register_user_bloc.dart';
import 'package:shleehcustomer/features/authentication/reset_password/presentation/bloc/reset/reset_password_bloc.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:shleehcustomer/features/buildings/presentation/bloc/buildings/buildings_bloc.dart';
import 'package:shleehcustomer/features/buildings/presentation/bloc/flat/flats_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/home_page/presentation/bloc/home/home_bloc.dart';
import 'package:shleehcustomer/features/home_page/presentation/pages/home_page.dart';
import 'package:shleehcustomer/features/landing/presentation/bloc/landing/landing_bloc.dart';
import 'package:shleehcustomer/features/landing/presentation/pages/landing_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/features/landing/presentation/pages/launch_screen.dart';
import 'core/styles/app_theme.dart';
import 'core/util/Constants.dart';
import 'core/util/cashed_data/cashed_file.dart';
import 'core/util/common_functions.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/settings/presentation/bloc/setting/setting_bloc.dart';
import 'injection_container.dart' as di;
import 'core/network/trusted_certificates.dart';
import 'core/favorites/favorites_cubit.dart';

late bool isAppLaunched;
late bool isLogin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // Must happen before any network call — see trusted_certificates.dart for
  // why (works around a server-side SSL chain issue causing
  // HandshakeException on some Android devices).
  await registerTrustedCertificates();
  isAppLaunched = await CasheFile().isAppLaunched();
  isLogin = await CasheFile().isLogin();
  CommonFunctions.pageNumberChalets = 1;

  await di.init();
  runApp(
    EasyLocalization(
      child: const MyApp(),
      supportedLocales: const [
        // Locale(VALUE_LANGUAGE_EN),
        Locale(VALUE_LANGUAGE_AR),
      ],
      path: 'resources/language',
      fallbackLocale: const Locale(VALUE_LANGUAGE_AR),
      startLocale: const Locale(VALUE_LANGUAGE_AR),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<LandingBloc>()..add(LandingEventObj()),
        ),
        BlocProvider(
          create: (_) => di.sl<ChaletsBloc>()..add(
            GetAllChaletsEvent(
              pageNumber: 1,
              body: const {
                "page": 1,
                "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
                "heightolow": 1,
                "rateheightolow": 0
              },
            ),
          ),
        ),
        BlocProvider(
          create: (_) => di.sl<BuildingsBloc>()..add(
            GetAllBuildingsEvent(
              pageNumber: 1,
              body: const {
                "page": 1,
                "pageSize": PAGE_SIZE_BUILDINGS_PAGINATION,
                "heightolow": 1,
                "rateheightolow": 0
              },
            ),
          ),
        ),
        BlocProvider(create: (_) => di.sl<LoginBloc>()),
        BlocProvider(create: (_) => di.sl<BookingsBloc>()),
        BlocProvider(create: (_) => di.sl<ResetBloc>()),
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
        BlocProvider(create: (_) => di.sl<FlatsBloc>()),

        BlocProvider(create: (_) => di.sl<SettingBloc>()),
        BlocProvider(create: (_) => di.sl<RegisterBloc>()),
        BlocProvider(create: (_) => di.sl<FavoritesCubit>()..load()),
      ],
      child: MaterialApp(
        // ✅ Don't wrap with Directionality - easy_localization handles it
        debugShowCheckedModeBanner: false,
        theme: appTheme,

        // ✅ These are provided by easy_localization
        localizationsDelegates: [
          ...context.localizationDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        title: '',
        home: const LaunchScreen(),
      ),
    );
  }
}