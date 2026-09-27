import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/biometric_auth.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/bloc/login/login_event.dart';
import 'package:shleehcustomer/features/booking/domain/entities/booking.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalets_map_screen.dart';
import 'package:shleehcustomer/features/settings/presentation/pages/management_user_screen.dart';
import 'package:shleehcustomer/features/settings/presentation/pages/privacy_screen.dart';
import 'package:shleehcustomer/features/settings/presentation/widgets/settings_widget/setting_data_row.dart';
import 'package:shleehcustomer/features/settings/presentation/widgets/settings_widget/support_btn.dart';

import '../../../../../core/strings/assets_path.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/app_bar_back.dart';
import '../../../../../core/widgets/text_icon.dart';
import '../../../../authentication/login/presentation/bloc/login/login_bloc.dart';
import '../../../../../core/favorites/favorites_cubit.dart';
import '../../bloc/setting/setting_bloc.dart';

class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({super.key});

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget>
    with SingleTickerProviderStateMixin {
  // ── Animation Controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _biometricEnabled = false;
  bool _biometricPayEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final enabled = await BiometricPrefs.isEnabled();
    final payEnabled = await BiometricPrefs.isPayEnabled();
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _biometricPayEnabled = payEnabled;
      });
    }
  }

  /// Turns fingerprint/Face ID login on or off. Both directions require a
  /// live successful authentication first — otherwise anyone who picks up
  /// an unlocked phone could just switch the protection off. The only
  /// exception is if the device has no biometrics available at all (e.g.
  /// removed after the setting was turned on), in which case disabling is
  /// allowed through so the guest doesn't get permanently stuck with a
  /// setting they can never turn off.
  Future<void> _toggleBiometric() async {
    final turningOn = !_biometricEnabled;
    final available = await BiometricAuthService.isAvailable();
    if (!mounted) return;

    if (!available) {
      if (turningOn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يوجد بصمة أو Face ID مُفعّل على هذا الجهاز'),
          ),
        );
        return;
      }
      await BiometricPrefs.setEnabled(false);
      if (mounted) setState(() => _biometricEnabled = false);
      return;
    }

    final confirmed = await BiometricAuthService.authenticate(
      reason: turningOn
          ? 'الرجاء تأكيد بصمتك لتفعيل الدخول السريع'
          : 'الرجاء تأكيد بصمتك لإيقاف الدخول بالبصمة',
    );
    if (!mounted) return;
    if (!confirmed) return;

    await BiometricPrefs.setEnabled(turningOn);
    if (mounted) setState(() => _biometricEnabled = turningOn);
  }

  /// Turns the "confirm with fingerprint before paying" setting on or off.
  /// Independent of the login toggle above — a guest can require a
  /// biometric check before payment even if they log in with a password.
  /// Same as [_toggleBiometric], both directions require a successful
  /// scan so the protection can't just be switched off by whoever is
  /// holding the unlocked phone.
  Future<void> _togglePayBiometric() async {
    final turningOn = !_biometricPayEnabled;
    final available = await BiometricAuthService.isAvailable();
    if (!mounted) return;

    if (!available) {
      if (turningOn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يوجد بصمة أو Face ID مُفعّل على هذا الجهاز'),
          ),
        );
        return;
      }
      await BiometricPrefs.setPayEnabled(false);
      if (mounted) setState(() => _biometricPayEnabled = false);
      return;
    }

    final confirmed = await BiometricAuthService.authenticate(
      reason: turningOn
          ? 'الرجاء تأكيد بصمتك لتفعيل تأكيد الدفع بالبصمة'
          : 'الرجاء تأكيد بصمتك لإيقاف تأكيد الدفع بالبصمة',
    );
    if (!mounted) return;
    if (!confirmed) return;

    await BiometricPrefs.setPayEnabled(turningOn);
    if (mounted) setState(() => _biometricPayEnabled = turningOn);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(context),
              ),

              // Profile Section
              if (CasheFile.isLoginUser)
                SliverToBoxAdapter(
                  child: _buildProfileSection(context),
                ),

              // Account Section
              if (CasheFile.isLoginUser)
                SliverToBoxAdapter(
                  child: _buildAccountSection(context),
                ),

              // Support Section
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SupportBtn(),
              )),

              // Bottom Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Section
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            getTextByKey(key: TranslationKey.keySettings),
            style: TextStyles.textStyleTitle(context).copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 4),
          Text(
            'أدر حسابك والتفضيلات الخاصة بك',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  // ── Profile Section
  Widget _buildProfileSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.9),
              primaryColor.withOpacity(0.7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar (right side in RTL)
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                CupertinoIcons.person_fill,
                size: 36,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            // Profile Info (center)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'أهلا وسهلا بك!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'أدر إعدادات حسابك الشخصية',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Arrow (left side in RTL)
            // Icon(
            //   Icons.arrow_back_ios_rounded,
            //   color: Colors.white.withOpacity(0.7),
            //   size: 18,
            // ),
          ],
        ),
      ),
    );
  }

  // ── Account Section
  Widget _buildAccountSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'الحساب',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  context: context,
                  icon: CupertinoIcons.person_fill,
                  title: getTextByKey(
                    key: TranslationKey.keyAccountManagement,
                  ),
                  onTap: () {
                    BlocProvider.of<SettingBloc>(context).add(GetUserEvent());
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const ManagementUserPage(
                        phoneNumber: "phoneNumber",
                      ),
                      withNavBar: false,
                    );
                  },
                  isFirst: true,
                ),
                _buildDivider(),
                _buildSettingItem(
                  context: context,
                  icon: CupertinoIcons.lock_fill,
                  title: getTextByKey(key: TranslationKey.keyPrivacy),
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const PrivacyScreen(),
                      withNavBar: false,
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  context: context,
                  icon: Icons.fingerprint,
                  title: 'تسجيل الدخول بالبصمة',
                  onTap: _toggleBiometric,
                  toggleValue: _biometricEnabled,
                ),
                _buildDivider(),
                _buildSettingItem(
                  context: context,
                  icon: Icons.verified_user_rounded,
                  title: 'تأكيد الدفع بالبصمة',
                  subtitle: 'اطلب بصمتك قبل إتمام أي عملية دفع',
                  onTap: _togglePayBiometric,
                  toggleValue: _biometricPayEnabled,
                ),
                _buildDivider(),
                _buildSettingItem(
                  context: context,
                  icon: CupertinoIcons.square_arrow_left,
                  title: 'تسجيل الخروج',
                  isDestructive: true,
                  onTap: () {
                    _showLogoutConfirmation(context);
                  },
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ── Support Section

  // ── Setting Item
  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isFirst = false,
    bool isLast = false,
    // When non-null, this row is a toggle (e.g. biometric login) — shows a
    // Switch instead of the usual "navigate into a sub-screen" chevron.
    // `onTap` still fires on either the row tap or the switch's own
    // onChanged, so callers only need one handler.
    bool? toggleValue,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFirst ? 16 : 0),
          topRight: Radius.circular(isFirst ? 16 : 0),
          bottomLeft: Radius.circular(isLast ? 16 : 0),
          bottomRight: Radius.circular(isLast ? 16 : 0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (toggleValue != null)
                Switch(
                  value: toggleValue,
                  activeColor: primaryColor,
                  onChanged: (_) => onTap(),
                )
              else
                Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.red.shade600
                            : Colors.grey.shade900,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.shade50
                      : primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: isDestructive ? Colors.red.shade600 : primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Divider
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: Colors.grey.shade100,
        height: 1,
        thickness: 1,
      ),
    );
  }

  // ── Dialogs

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تسجيل الخروج'),
          content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                BlocProvider.of<LoginBloc>(context)
                    .add(UserLoginInitialEvent());
                // Favorites are per-account (backend-synced) — clear them
                // on logout so the next guest/user never sees the previous
                // account's list, even for a moment.
                BlocProvider.of<FavoritesCubit>(context).clear();
                CasheFile().setLogout(context);
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
