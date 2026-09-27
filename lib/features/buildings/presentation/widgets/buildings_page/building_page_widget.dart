import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/buildings/presentation/pages/building_filter_page.dart';
import 'package:shleehcustomer/features/buildings/presentation/pages/buildings_map_screen.dart';
import '../../../../../core/strings/assets_path.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/text_icon.dart';
import '../../bloc/buildings/buildings_bloc.dart';
import '../../../domain/entities/building.dart';
import 'building_list_widget.dart';

class BuildingsPageWidget extends StatefulWidget {
  final List<Building> Buildings;
  final bool BuildingsStateIsEmpty;
  final BuildContext buildContext;

  const BuildingsPageWidget({
    Key? key,
    required this.Buildings,
    required this.BuildingsStateIsEmpty,
    required this.buildContext,
  }) : super(key: key);

  @override
  State<BuildingsPageWidget> createState() => _BuildingsPageWidgetState();
}

class _BuildingsPageWidgetState extends State<BuildingsPageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showFilterBadge = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with filter controls
                _buildHeaderSection(context),

                // Main Buildings list
                Expanded(
                  child: _buildBuildingsList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build header section with date filter and action buttons
  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Filter Button
          // _buildDateFilterButton(context),
          const SizedBox(height: 16),

          // Action buttons row
          _buildActionButtonsRow(context),
        ],
      ),
    );
  }

  /// Date filter button with calendar icon
  Widget _buildDateFilterButton(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      ),
      child: GestureDetector(
        onTap: () => _navigateToDateFilter(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.9), primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    getTextByKey(key: TranslationKey.keyBuildingsByDates),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Map action button — full-width prominent card.
  ///
  /// Previously this sat inside a spaceEvenly Row as the only child
  /// (the filter button was commented out), which left it looking
  /// like a tiny centered icon floating in a big empty white bar.
  /// Now it's a deliberate full-width card, same visual weight as
  /// the date-filter button above it, so the space is used
  /// intentionally instead of looking like leftover UI.
  Widget _buildActionButtonsRow(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _navigateToMap(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primaryColor.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.pin_drop_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        getTextByKey(key: TranslationKey.keyMap),
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _mapSubtitle(),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Small helper for the map button's subtitle text. Kept as a
  /// simple string here rather than another translation-key lookup
  /// so it's easy to swap for a real key once you have one, e.g.
  /// TranslationKey.keyViewOnMap.
  String _mapSubtitle() => 'اعرض جميع المباني على الخريطة';

  /// Build buildings list with fade animation
  Widget _buildBuildingsList() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.8, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.3, 1, curve: Curves.easeOut),
        ),
      ),
      child: BlocBuilder<BuildingsBloc, BuildingsState>(
        builder: (context, state) {
          bool lastEmpty = false;

          if (state is LoadedBuildingsState) {
            lastEmpty = state.lastEmpty;
          }

          return BuildingListWidget(
            buildings: widget.Buildings,
            lastEmpty: lastEmpty,
          );
        },
      ),
    );
  }

  /// Navigate to date filter page
  void _navigateToDateFilter(BuildContext context) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const BuildingFilterPage(filterType: "date"),
      withNavBar: false,
    );
  }

  /// Navigate to filter page
  void _navigateToFilter(BuildContext context) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const BuildingFilterPage(filterType: "normal"),
      withNavBar: false,
    );
  }

  /// Navigate to map page
  void _navigateToMap(BuildContext context) {
    final buildingsBloc = BlocProvider.of<BuildingsBloc>(context);
    buildingsBloc.add(GetAllBuildingsMapEvent());

    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: BlocProvider.value(
        value: buildingsBloc,
        child: BuildingsMapScreen(),
      ),
      withNavBar: false,
    );
  }
}