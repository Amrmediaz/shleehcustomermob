import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalet_filter_page.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalets_map_screen.dart';
import 'package:shleehcustomer/features/authentication/login/data/models/user_profile.dart';
import '../../../../../core/strings/assets_path.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/cashed_data/cashed_file.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/text_icon.dart';
import '../../../domain/entities/chalet.dart';
import 'chalet_list_widget.dart';
import 'chalet_quick_filters.dart';

class ChaletsPageWidget extends StatefulWidget {
  final List<Chalet> chalets;
  final bool chaletsStateIsEmpty;
  final BuildContext buildContext;

  const ChaletsPageWidget({
    Key? key,
    required this.chalets,
    required this.chaletsStateIsEmpty,
    required this.buildContext,
  }) : super(key: key);

  @override
  State<ChaletsPageWidget> createState() => _ChaletsPageWidgetState();
}

class _ChaletsPageWidgetState extends State<ChaletsPageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showFilterBadge = false;
  // Drives the filters+WhatsApp FAB cluster's slide/fade — hidden while the
  // chalets list is scrolling down (out of the way of content), shown again
  // once the user scrolls back up, same pattern as a hiding bottom nav bar.
  bool _fabsVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
    // Home is a tab kept alive by persistent_bottom_nav_bar, so initState
    // only ever runs once — a plain "load once" read of the cached profile
    // would never pick up a name changed later on the profile screen. The
    // greeting instead listens to CasheFile.currentUser (see build below),
    // this call just makes sure that notifier has a value at all if this
    // tab happens to be the first screen built after a cold start.
    CasheFile.loadUser();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<UserScrollNotification>(
      // Bubbles up from the chalets ListView below — reverse = user
      // scrolling down (toward more content), forward = scrolling back up.
      onNotification: (notification) {
        if (notification.direction == ScrollDirection.reverse && _fabsVisible) {
          setState(() => _fabsVisible = false);
        } else if (notification.direction == ScrollDirection.forward && !_fabsVisible) {
          setState(() => _fabsVisible = true);
        }
        return false;
      },
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section (hero + quick filters)
                      _buildHeaderSection(context),

                      // Main chalets list
                      Expanded(
                        child: _buildChaletsList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Floating quick-actions button — bundles the location/dates/price
          // chips and the map shortcut into one entry point that opens them
          // as a bottom sheet, instead of a permanent card + a separate
          // floating map button both eating space/attention on their own.
          // "end" here means the left side — the app runs RTL (see
          // Directionality in HomePage), so PositionedDirectional's `end`
          // resolves to left instead of hardcoding a side that would flip
          // meaning if direction ever changed. Stacked with the WhatsApp
          // shortcut directly below it, both sliding/fading out together
          // while the list is scrolling down.
          PositionedDirectional(
            end: 16,
            bottom: 16,
            child: _buildFabVisibility(child: _buildQuickActionsFab(context)),
          ),
          PositionedDirectional(
            end: 16,
            bottom: 78,
            child: _buildFabVisibility(child: _buildWhatsAppFab(context)),
          ),
        ],
      ),
    );
  }

  /// Shared slide+fade wrapper for the two stacked FABs — hidden state
  /// slides them down out of view and fades them out; visible state is the
  /// normal resting position. `IgnorePointer` while hidden so a
  /// mid-animation tap can't land on a button that's supposed to be gone.
  Widget _buildFabVisibility({required Widget child}) {
    return IgnorePointer(
      ignoring: !_fabsVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        offset: _fabsVisible ? Offset.zero : const Offset(0, 0.6),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: _fabsVisible ? 1 : 0,
          child: child,
        ),
      ),
    );
  }

  /// Round WhatsApp shortcut — stacked directly under the filters FAB (same
  /// corner) instead of spread to the opposite side, so both read as one
  /// floating cluster. Same support number used throughout the app
  /// (CommonFunctions.sendMessageToWhatsApp / +968 93866893).
  Widget _buildWhatsAppFab(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () async {
          final userProfile = await CasheFile.loadUser();
          final customerName = userProfile != null
              ? '${userProfile.firstName} ${userProfile.lastName}'.trim()
              : '';
          if (!context.mounted) return;
          await CommonFunctions.sendMessageToWhatsApp(
            context,
            'اهلا وسهلا${customerName.isNotEmpty ? ' ، معك $customerName' : ''}، عندي استفسار بخصوص الحجز',
          );
        },
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF25D366),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF25D366).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: SvgPicture.string(
            '<svg viewBox="0 0 448 512" xmlns="http://www.w3.org/2000/svg">'
            '<path fill="#ffffff" d="M380.9 97.1C339 55.1 283.2 32 223.9 32c-122.4 0-222 99.6-222 222 '
            '0 39.1 10.2 77.3 29.6 111L0 480l117.7-30.9c32.4 17.7 68.9 27 106.1 27h.1c122.3 0 224.1-99.6 '
            '224.1-222 0-59.3-25.2-115-67.1-157zm-157 341.6c-33.2 0-65.7-8.9-94-25.7l-6.7-4-69.8 18.3L72 '
            '359.2l-4.4-7c-18.5-29.4-28.2-63.3-28.2-98.2 0-101.7 82.8-184.5 184.6-184.5 49.3 0 95.6 19.2 '
            '130.4 54.1 34.8 34.9 56.2 81.2 56.1 130.5 0 101.8-84.9 184.6-186.6 184.6zm101.2-138.2c-5.5-2.8 '
            '-32.8-16.2-37.9-18-5.1-1.9-8.8-2.8-12.5 2.8-3.7 5.6-14.3 18-17.6 21.8-3.2 3.7-6.5 4.2-12 1.4 '
            '-32.6-16.3-54-29.1-75.5-66-5.7-9.8 5.7-9.1 16.3-30.3 1.8-3.7.9-6.9-.5-9.7-1.4-2.8-12.5-30.1 '
            '-17.1-41.2-4.5-10.8-9.1-9.3-12.5-9.5-3.2-.2-6.9-.2-10.6-.2-3.7 0-9.7 1.4-14.8 6.9-5.1 5.6 '
            '-19.4 19-19.4 46.3 0 27.3 19.9 53.7 22.6 57.4 2.8 3.7 39.1 59.7 94.8 83.8 35.2 15.2 49 16.5 '
            '66.6 13.9 10.7-1.6 32.8-13.4 37.4-26.4 4.6-13 4.6-24.1 3.2-26.4-1.3-2.5-5-3.9-10.5-6.6z"/>'
            '</svg>',
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }

  /// Build header section with date filter and action buttons.
  ///
  /// Was a flat grey/white block from the very top of the page — user
  /// feedback was that the whole home page reads as "all white", nothing
  /// to anchor it. Now a colored gradient band (app's own primaryColor)
  /// sits at the very top with a short greeting, and the search
  /// card + action row float over its rounded bottom edge, so the page
  /// has a real "hero" moment instead of starting flat.
  Widget _buildHeaderSection(BuildContext context) {
    // Just the hero now — the location/dates/price quick filters used to
    // sit permanently underneath it as their own card, eating space above
    // the list at all times. They're now bundled with the map shortcut
    // into one floating "بحث" button (see build()'s Stack) that opens them
    // as a bottom sheet on demand instead of always being on screen.
    return FadeTransition(
      opacity: _animationController,
      child: _buildColoredHeroHeader(context),
    );
  }

  /// The colored hero band itself — a short greeting over a primaryColor
  /// gradient with rounded bottom corners. Deliberately simple (no extra
  /// imagery) so it reads as a clean brand moment rather than competing
  /// with the search card that overlaps it.
  Widget _buildColoredHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      // Bottom padding trimmed since the search bar (added below) now
      // fills what used to be empty space here, and the quick-filters card
      // below still only needs a modest overlap to float on the rounded
      // corner.
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
      decoration: BoxDecoration(
        // Flat solid color instead of a gradient — the gradient faded to a
        // lighter shade toward the bottom-right, which read as a second,
        // different purple next to the flat solid bar above it. Same exact
        // primaryColor as that bar now, so the whole header (logo bar +
        // this) is genuinely one color, one part.
        color: primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.holiday_village_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              ValueListenableBuilder<UserProfile?>(
                valueListenable: CasheFile.currentUser,
                builder: (context, userProfile, _) {
                  final name = userProfile != null
                      ? '${userProfile.firstName} ${userProfile.lastName}'.trim()
                      : '';
                  return Text(
                    name.isNotEmpty ? 'أهلاً بك $name 👋' : 'أهلاً بك 👋',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15.5),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // "Find your chalet" search entry — used to float on its own
          // white card below the purple band; now it lives right here,
          // right under the greeting, as the one clear primary action
          // inside the hero itself instead of a separate section.
          SizedBox(width: double.infinity, child: _buildFilterEntryButton(context)),
        ],
      ),
    );
  }

  /// Date filter button with calendar icon
  // Widget _buildDateFilterButton(BuildContext context) {
  //   return ScaleTransition(
  //     scale: Tween<double>(begin: 0.9, end: 1).animate(
  //       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
  //     ),
  //     child: GestureDetector(
  //       onTap: () => _navigateToDateFilter(context),
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [primaryColor.withOpacity(0.9), primaryColor.withOpacity(0.7)],
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //           ),
  //           borderRadius: BorderRadius.circular(12),
  //           boxShadow: [
  //             BoxShadow(
  //               color: primaryColor.withOpacity(0.2),
  //               blurRadius: 8,
  //               offset: const Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Row(
  //               children: [
  //                 const Icon(
  //                   Icons.calendar_today_rounded,
  //                   color: Colors.white,
  //                   size: 20,
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Text(
  //                   getTextByKey(key: TranslationKey.keyChaletsByDates),
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.w600,
  //                     fontSize: 14,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Icon(
  //               Icons.arrow_forward_rounded,
  //               color: Colors.white.withOpacity(0.8),
  //               size: 18,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// Primary "find your chalet" entry point — doubles as the filter
  /// launcher. Copy and styling shift once filters are actually on, so it
  /// also communicates state instead of always saying the same static
  /// word.
  Widget _buildFilterEntryButton(BuildContext context) {
    final bool active = _showFilterBadge;
    return GestureDetector(
      onTap: () => _navigateToFilter(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: active ? primaryColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? primaryColor.withOpacity(0.35) : Colors.grey.shade200,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                active ? Icons.tune_rounded : Icons.search_rounded,
                color: primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                active
                    ? getTextByKey(key: TranslationKey.keyFiltersActiveTapToEdit)
                    : getTextByKey(key: TranslationKey.keyFindIdealChalet),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? primaryColor : Colors.grey.shade800,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            // The app is always RTL, so this uses the already-left-pointing
            // icon directly rather than a "forward" arrow that would need
            // mirroring (Icon has no matchTextDirection param to do that).
            Icon(Icons.arrow_back_ios_new_rounded, size: 12, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  /// Floating quick-actions button — was two separate things (a permanent
  /// location/dates/price card + a floating map button). Both are now
  /// bundled behind this one button: tapping it opens a bottom sheet
  /// ("قايمة تظهر") holding the quick filters plus a map shortcut, so
  /// neither takes up permanent space above the list.
  Widget _buildQuickActionsFab(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => _openQuickActionsSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                // "بحث" (search) was vague for a button that actually opens
                // filters + a map shortcut — "فلاتر" (filters) matches the
                // tune icon and what the sheet actually contains.
                'فلاتر',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The sheet the FAB above opens — location/dates/price quick filters
  /// (same ChaletQuickFilters used before, unchanged logic) plus a map
  /// shortcut underneath, all in one dismissible list instead of two
  /// permanently-visible pieces of UI.
  void _openQuickActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Header: icon badge + title/subtitle + explicit close button
              // — was just a bare title before.
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.tune_rounded, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بحث سريع',
                          style: TextStyles.textStyleTitle(sheetContext).copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'اختر ما تبحث عنه لعرض النتائج',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(sheetContext),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // One card holding the quick filters + the map shortcut as a
              // matching list row — was a title, a separate card, and a
              // differently-styled tinted map button all sitting loose.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    const ChaletQuickFilters(),
                    Divider(height: 1, color: Colors.grey.shade200),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _navigateToMap(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Icon(Icons.pin_drop_rounded, color: primaryColor, size: 18),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'استكشف على الخريطة',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade300, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build buildings list with fade animation
  Widget _buildChaletsList() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.8, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.3, 1, curve: Curves.easeOut),
        ),
      ),
      child: BlocBuilder<ChaletsBloc, ChaletsState>(  // ← ADD THIS
        builder: (context, state) {
          bool lastEmpty = false;

          if (state is LoadedChaletsState) {
            lastEmpty = state.lastEmpty;  // ← GET FROM BLOC!
          }

          return ChaletListWidget(
            chalets: widget.chalets,
            lastEmpty: lastEmpty,  // ← NOW DYNAMIC!
          );
        },
      ),
    );
  }

  /// Navigate to date filter page
  void _navigateToDateFilter(BuildContext context) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const ChaletFilterPage(filterType: "date"),
      withNavBar: false,
    );
  }

  /// Navigate to filter page
  void _navigateToFilter(BuildContext context) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const ChaletFilterPage(filterType: "normal"),
      withNavBar: false,
    );
  }

  /// Navigate to map page
  void _navigateToMap(BuildContext context) {
    BlocProvider.of<ChaletsBloc>(context).add(GetAllChaletsMapEvent());

    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: ChaletsMapScreen(),
      withNavBar: false,
    );
  }
}