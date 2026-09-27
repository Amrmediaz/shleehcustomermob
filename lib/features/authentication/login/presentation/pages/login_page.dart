import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/widgets/login_page/form_widget.dart';
import 'package:shleehcustomer/features/home_page/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/biometric_auth.dart';
import '../../../../../core/util/snackbar_message.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../../../../buildings/presentation/bloc/buildings/buildings_bloc.dart';
import '../../../../chalets/presentation/bloc/chalets/chalets_bloc.dart';
import '../../../../../core/favorites/favorites_cubit.dart';
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
            listener: (context, state) async {
              if (state is MessageLoginState) {
                if (state.isMainLogin) {
                  BlocProvider.of<ChaletsBloc>(context).add(
                      GetAllChaletsEvent(
                        pageNumber: 1,
                        body: const {
                          "page": 1,
                          "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
                          "heightolow": 1,
                          "rateheightolow": 0
                        },
                      ),

                  );
                  BlocProvider.of<BuildingsBloc>(context).add(
              GetAllBuildingsEvent(
              pageNumber: 1,
              body: const {
              "page": 1,
              "pageSize": PAGE_SIZE_BUILDINGS_PAGINATION,
              "heightolow": 1,
              "rateheightolow": 0
              },
              ),
              );
                  // Favorites are per-account now (backend-synced), so
                  // reload them right after a successful login instead of
                  // leaving whatever was loaded for the previous
                  // session/guest state.
                  BlocProvider.of<FavoritesCubit>(context).load();

                  if (context.mounted) {
                    await _maybeOfferBiometricEnable(context);
                  }
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false);
                  }
                }
              } else if (state is ErrorLoginState) {
                if (state.isMainLogin) {

                  CommonFunctions.showBottomDialog(
                      context,
                    icon:    Icon(
                        Icons.error,
                        color: primaryColor,
                        size: CommonFunctions.calculateIconSize(context),
                      ),
                      title:  state.message,
                       description: 'تأكد من رقم الهاتف والرمز السري');
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

  /// One-time, non-blocking offer to enable fingerprint/Face ID login,
  /// shown right after a successful password login — only if the device
  /// actually has biometrics enrolled, it isn't already enabled, and the
  /// guest hasn't been asked before (see BiometricPrefs.wasAsked). The
  /// setting can also always be changed later from the settings screen, so
  /// declining here isn't a dead end.
  Future<void> _maybeOfferBiometricEnable(BuildContext context) async {
    final alreadyEnabled = await BiometricPrefs.isEnabled();
    final alreadyAsked = await BiometricPrefs.wasAsked();
    if (alreadyEnabled || alreadyAsked) return;

    final available = await BiometricAuthService.isAvailable();
    if (!available) return;

    await BiometricPrefs.markAsked();
    if (!context.mounted) return;

    final wantsIt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الدخول بالبصمة'),
        content: const Text(
            'هل ترغب بتفعيل الدخول ببصمة الإصبع أو Face ID بدلاً من كتابة كلمة المرور في كل مرة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لاحقاً'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );

    if (wantsIt != true) return;

    // Confirm the device can actually authenticate right now before
    // committing to the setting — avoids enabling something that then
    // fails on the very next launch.
    final confirmed = await BiometricAuthService.authenticate(
      reason: 'الرجاء تأكيد بصمتك لتفعيل الدخول السريع',
    );
    if (confirmed) {
      await BiometricPrefs.setEnabled(true);
    }
  }
}
