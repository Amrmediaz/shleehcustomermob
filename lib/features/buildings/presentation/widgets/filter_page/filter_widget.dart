import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/buildings/presentation/pages/building_filter_page.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/styles/text/text_style.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/app_bar_back.dart';
import '../../../../Buildings/presentation/pages/Buildings_by_filter_page.dart';
import '../../bloc/buildings/buildings_bloc.dart';
import '../../bloc/buildings/buildings_bloc.dart';

class FilterWidget extends StatefulWidget {
  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

// ---------------------------------------------------------------------------
// Data + Arabic display maps.
// IMPORTANT: dropdown/service `value`s sent to the API always stay the
// original English keys below. The *Arabic maps are display-only* and never
// touch the request body.
// ---------------------------------------------------------------------------




class _FilterWidgetState extends State<FilterWidget> {
  String? selectedGovernorate;
  String? selectedState;
  RangeValues selectedPriceRange = const RangeValues(20, 200);

  // All keys stay English — this map IS the payload sent to the API.
  Map<String, bool> selectedServices = {
    'menPool': false,
    'womenPool': false,
    'grill': false,
    'volleyBall': false,
    'animals': false,
    'childPool': false,
    'football': false,
    'games': false,
    'childGames': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header / back button
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppBarBack(
                        leadingWidgetAction: () => Navigator.pop(context),
                      ),
                    ),
                    Text(
                      getTextByKey(key: TranslationKey.keyFilter),
                      style: TextStyles.textStyleTitle(context).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  _sectionTitle(context, TranslationKey.keyLocation),
                  const SizedBox(height: 10),

                  // Governorate selector
                  _buildDropdownCard(
                    icon: Icons.map_outlined,
                    hint:
                    getTextByKey(key: TranslationKey.keySelectGovernorate),
                    value: selectedGovernorate,
                    items: governorates,
                    displayBuilder: (v) => governoratesEnglishToArabic[v] ?? v,
                    onChanged: (v) => setState(() => selectedGovernorate = v),
                  ),
                  const SizedBox(height: 12),

                  // State selector
                  _buildDropdownCard(
                    icon: Icons.location_city_rounded,
                    hint: getTextByKey(key: TranslationKey.keySelectState),
                    value: selectedState,
                    items: states,
                    displayBuilder: (v) => statesEnglishToArabicFilter[v] ?? v,
                    onChanged: (v) => setState(() => selectedState = v),
                  ),

                  const SizedBox(height: 28),

                  // Price range
                  _sectionTitle(context, TranslationKey.keySelectPriceRange),
                  const SizedBox(height: 10),
                  _buildPriceRangeCard(context),

                  const SizedBox(height: 28),

                  // Services
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle(context, TranslationKey.keySelectServices),
                      if (selectedServices.values.any((v) => v))
                        GestureDetector(
                          onTap: () => setState(() {
                            selectedServices.updateAll((k, v) => false);
                          }),
                          child: Text(
                  "إعادة تعيين",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildServicesGrid(context),
                ],
              ),
            ),

            // Sticky footer with Reset + Apply
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _resetFilters,
                      icon: Icon(Icons.refresh_rounded,
                          color: Colors.grey.shade500),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ActionBtn(
                        onPressed: _applyFilters,
                        btnTitle:
                        getTextByKey(key: TranslationKey.keyApplyFilters),
                        btnColor: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Sections
  // ---------------------------------------------------------------------

  Widget _sectionTitle(BuildContext context, String key) {
    return Text(
      getTextByKey(key: key),
      style: TextStyles.textStyleTitle(context).copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  /// Reusable dropdown card. `displayBuilder` controls only what text is
  /// shown; `value` / `onChanged` always carry the raw English API key.
  Widget _buildDropdownCard({
    required IconData icon,
    required String hint,
    required String? value,
    required List<String> items,
    required String Function(String) displayBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(hint, style: TextStyles.textStyleBody(context)),
                value: value,
                onChanged: onChanged,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade500),
                items: items.map<DropdownMenuItem<String>>((String v) {
                  return DropdownMenuItem<String>(
                    value: v,
                    child: Text(
                      displayBuilder(v),
                      style: TextStyles.textStyleBody(context),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _priceChip(context, selectedPriceRange.start.round()),
              Icon(Icons.arrow_forward_rounded,
                  size: 14, color: Colors.grey.shade400),
              _priceChip(context, selectedPriceRange.end.round()),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primaryColor,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: primaryColor,
              overlayColor: primaryColor.withOpacity(0.15),
              rangeThumbShape:
              const RoundRangeSliderThumbShape(enabledThumbRadius: 9),
              trackHeight: 4,
            ),
            child: RangeSlider(
              values: selectedPriceRange,
              min: 15,
              max: 250,
              divisions: 47,
              labels: RangeLabels(
                selectedPriceRange.start.round().toString(),
                selectedPriceRange.end.round().toString(),
              ),
              onChanged: (RangeValues newRange) {
                setState(() => selectedPriceRange = newRange);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("15 ${getTextByKey(key: TranslationKey.keyOMR)}",
                    style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                Text("250 ${getTextByKey(key: TranslationKey.keyOMR)}",
                    style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceChip(BuildContext context, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$value ${getTextByKey(key: TranslationKey.keyOMR)}",
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    return GridView.count(
      childAspectRatio: 2.8,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: services.map((String service) {
        final bool isSelected = selectedServices[service] ?? false;
        return GestureDetector(
          onTap: () {
            setState(() => selectedServices[service] = !isSelected);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                isSelected ? primaryColor : Colors.grey.withOpacity(0.15),
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
                  : [],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    serviceIcons[service] ?? Icons.check_circle_outline_rounded,
                    size: 18,
                    color: isSelected ? Colors.white : primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    servicesEnglishToArabic[service] ?? service,
                    style: TextStyles.textStyleHelper(context).copyWith(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 16),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------

  void _resetFilters() {
    setState(() {
      selectedGovernorate = null;
      selectedState = null;
      selectedPriceRange = const RangeValues(20, 200);
      selectedServices.updateAll((k, v) => false);
    });
  }

  void _applyFilters() {
    final filterBody = {
      "serviesList": selectedServices.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
      "fromPrice": selectedPriceRange.start.toInt(),
      "toPrice": selectedPriceRange.end.toInt(),
      "state": selectedState,
      "governorate": selectedGovernorate,
    };

    BlocProvider.of<BuildingsBloc>(context).add(GetAllBuildingsEvent(
      pageNumber: CommonFunctions.pageNumberbuildings,
      body: {
        "page": 1,
        "pageSize": PAGE_SIZE_BUILDINGS_PAGINATION,
        ...filterBody,
      },
    ));

    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: BuildingsByFilterPage(filterBody: filterBody),
      withNavBar: false,
    );
  }
}