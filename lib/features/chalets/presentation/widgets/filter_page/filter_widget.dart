import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalets_by_filter_page.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/styles/text/text_style.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/app_bar_back.dart';
import '../../bloc/chalets/chalets_bloc.dart';

// ---------------------------------------------------------------------------
// NOTE ON ASSUMPTIONS (read before dropping this in):
//
// 1. Add this import at the top of the file (not shown here since the
//    original snippet started at the class declaration):
//      import 'package:calendar_date_picker2/calendar_date_picker2.dart';
//
// 2. `governorates`, `states`, `services`, `serviceIcons`, `primaryColor`,
//    `governoratesEnglishToArabic`, `statesEnglishToArabicFilter`,
//    `servicesEnglishToArabic`, `TextStyles`, `AppBarBack`, `ActionBtn`,
//    `getTextByKey`, `TranslationKey`, `ChaletsBloc`, `GetAllChaletsEvent`,
//    `ChaletsByFilterPage`, `PersistentNavBarNavigator`, `CommonFunctions`,
//    and `PAGE_SIZE_CHALETS_PAGINATION` are all assumed to already exist
//    exactly as in your original file — untouched here.
//
// 3. `formatDate(DateTime)` is assumed to already exist elsewhere in your
//    codebase (your own CalendarDatePicker2 snippet already calls it), so
//    it isn't redefined here.
//
// 4. New TranslationKey entries you'll need to add (with translations) —
//    see translation_keys.dart and translations.json alongside this file:
//      keyChaletType, keySelectChaletType, keyName, keySearchByName,
//      keyRate, keyStar, keyStars, keyCapacity, keyBedrooms, keyBathrooms,
//      keyLivingRooms, keyLandscape, keyBestSeason, keyArea,
//      keySelectDates, keyConfirm, keyMoreFilters
//    Until you add them, swap those getTextByKey(...) calls for plain
//    strings if you want to compile immediately.
//
// 5. You only gave me the Arabic labels for chaletType ('شاليه' -> Chalet,
//    'استراحة' -> Resort, 'كوخ' -> Hut). I've inverted them below into
//    `chaletTypeEnglishToArabic` to match the English-key convention used
//    by `governoratesEnglishToArabic` / `statesEnglishToArabicFilter`.
//    landscape / bestSeason / area have no lists yet, so they're plain
//    search TextFields for now — send me their value lists + Arabic maps
//    whenever you have them and I'll convert those to chip selectors too.
//
// 6. UX pass in this version:
//    - chaletType and capacity/bedrooms/bathrooms/livingRooms are now
//      tappable chip pills instead of dropdown menus — one tap instead of
//      open-menu-then-select, and every option is visible up front.
//    - name / landscape / best season are tucked behind a collapsible
//      "More filters" section (collapsed by default) so the main screen
//      isn't a huge wall of fields — most users only care about
//      location, dates, price, and rooms.
//    - the Apply button now shows a live badge with the number of active
//      filters, and the Reset icon greys itself out when there's nothing
//      to reset.
// ---------------------------------------------------------------------------

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

// ── Duplicate governorate/state handling ───────────────────────────────
// Different owners/systems have entered the same governorate or state
// under slightly different spellings — most notably "Dohfar" vs the
// correct "Dhofar" (see the typo check already living in
// ChaletDetailWidget._getLocationTextHelper). If the raw `governorates`/
// `states` lists contain both variants (or the same value twice from
// different sources), Flutter's DropdownButton crashes with "There
// should be exactly one item with [DropdownButton]'s value" the moment
// two entries collide, and even when it doesn't crash outright, the
// user sees the same place listed twice.
//
// Fix: every raw value is passed through a canonicalizer before it ever
// reaches the dropdown's `items` or `value`, so aliases collapse to one
// entry and exact duplicates are removed regardless of which system (or
// how many different ones) entered the data.

// Add any further known misspellings/variants here as they turn up —
// key is the raw value as it might appear in the data, value is the
// single canonical form used everywhere in the UI and in API requests.
const Map<String, String> _governorateAliases = {
  'Dohfar': 'Dhofar',
  'dohfar': 'Dhofar',
  'dhofar': 'Dhofar',
  'DHOFAR': 'Dhofar',
};

const Map<String, String> _stateAliases = {
  // e.g. 'Al mazyona': 'AL mazyona',
};

// Fixed, small enum — no raw/duplicate-data problem like governorate/state,
// so no aliasing/dedup machinery needed, just a straight display map.
// (Values you gave me were Arabic -> English; inverted to English -> Arabic
// to match the convention of the other display maps.)
const Map<String, String> chaletTypeEnglishToArabic = {
  'Chalet': 'شاليه',
  'Resort': 'استراحة',
  'Hut': 'كوخ',
};

/// Strips zero-width/directional marks and BOM, and normalizes
/// non-breaking spaces to regular ones, before trimming. Different
/// input systems/keyboards/CMS panels can inject these invisible
/// characters — two values that look pixel-identical on screen (e.g.
/// "Salalah" vs "Salalah") otherwise still fail an exact or
/// case-insensitive match and keep showing up as separate items.
String _stripInvisibleChars(String value) {
  return value
      .replaceAll('​', '') // zero-width space
      .replaceAll('‌', '') // zero-width non-joiner
      .replaceAll('‍', '') // zero-width joiner
      .replaceAll('‎', '') // left-to-right mark
      .replaceAll('‏', '') // right-to-left mark
      .replaceAll('﻿', '') // byte-order mark
      .replaceAll(' ', ' ') // non-breaking space -> regular space
      .trim();
}

// Simple trim-only aliasing missed two other real-world cases that kept
// صلالة (Salalah) showing up duplicated:
//   1. Case-only variants ("Salalah" vs "SALALAH"/"salalah").
//   2. Some system entering the *Arabic label itself* ("صلالة") as the
//      raw state value instead of the English key ("Salalah") — so one
//      chalet's state is "Salalah" and another's is literally "صلالة",
//      and both render as "صلالة" in the dropdown, looking duplicated
//      even though they're technically different strings.
// Fixed below by matching a raw value against BOTH the English keys
// (case-insensitively) and the Arabic values of the authoritative
// display maps, always normalizing to the map's English key — that key
// is "the correct value" this picks, not whichever variant happened to
// appear first in the raw list.
String _canonicalGovernorate(String value) {
  final cleaned = _stripInvisibleChars(value);
  if (_governorateAliases.containsKey(cleaned)) {
    return _governorateAliases[cleaned]!;
  }
  final lower = cleaned.toLowerCase();
  for (final entry in governoratesEnglishToArabic.entries) {
    if (entry.key.toLowerCase() == lower) return entry.key;
    if (entry.value == cleaned) return entry.key; // Arabic label entered directly
  }
  return cleaned;
}

String _canonicalState(String value) {
  final cleaned = _stripInvisibleChars(value);
  if (_stateAliases.containsKey(cleaned)) {
    return _stateAliases[cleaned]!;
  }
  final lower = cleaned.toLowerCase();
  for (final entry in statesEnglishToArabicFilter.entries) {
    if (entry.key.toLowerCase() == lower) return entry.key;
    if (entry.value == cleaned) return entry.key; // Arabic label entered directly
  }
  return cleaned;
}

/// Maps every entry through [canonicalize] and drops anything that
/// collapses to a value already seen (or to an empty string), so the
/// dropdown never ends up with two items representing the same place —
/// whether that duplication came from an exact repeated string or from
/// a typo/casing variant like "Dohfar".
List<String> _dedupeLocationList(
    List<String> raw,
    String Function(String) canonicalize,
    ) {
  final seen = <String>{};
  final result = <String>[];
  for (final item in raw) {
    final canonical = canonicalize(item);
    if (canonical.isEmpty) continue;
    if (seen.add(canonical)) {
      result.add(canonical);
    }
  }
  return result;
}

class _FilterWidgetState extends State<FilterWidget> {
  String? selectedGovernorate;
  String? selectedState;
  RangeValues selectedPriceRange = const RangeValues(20, 200);

  // ── New filter fields ────────────────────────────────────────────────
  String? selectedChaletType;
  String? selectedCapacity;
  String? selectedBedrooms;
  String? selectedBathrooms;
  String? selectedLivingRooms;
  int selectedRate = 0; // 0 = no minimum rating selected
  List<DateTime?>? dates; // dates![0] = start, dates![1] = end

  final TextEditingController nameController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController landscapeController = TextEditingController();
  final TextEditingController bestSeasonController = TextEditingController();

  final DateTime currentDate = DateTime.now();

  // Collapsed by default so the screen doesn't open with every single
  // field expanded — most users only ever touch location/dates/price.
  bool _showMoreFilters = false;

  static const List<String> _roomCountOptions = ['1', '2', '3', '4', '5+'];
  static const RangeValues _defaultPriceRange = RangeValues(20, 200);

  // Deduplicated + canonicalized once per widget lifetime instead of on
  // every rebuild. These (not the raw `governorates`/`states` lists) are
  // what actually get handed to the dropdowns below.
  late final List<String> _governorateItems =
  _dedupeLocationList(governorates, _canonicalGovernorate);
  late final List<String> _stateItems =
  _dedupeLocationList(states, _canonicalState);

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

  /// Total number of filters currently active, across every section.
  /// Drives the badge on the Apply button and whether Reset is enabled.
  int get _activeFilterCount {
    int count = 0;
    if (selectedGovernorate != null) count++;
    if (selectedState != null) count++;
    if (areaController.text.trim().isNotEmpty) count++;
    if (selectedChaletType != null) count++;
    if (dates != null && dates!.isNotEmpty && dates!.first != null) count++;
    if (selectedPriceRange.start != _defaultPriceRange.start ||
        selectedPriceRange.end != _defaultPriceRange.end) count++;
    if (selectedCapacity != null) count++;
    if (selectedBedrooms != null) count++;
    if (selectedBathrooms != null) count++;
    if (selectedLivingRooms != null) count++;
    if (selectedRate > 0) count++;
    if (nameController.text.trim().isNotEmpty) count++;
    if (landscapeController.text.trim().isNotEmpty) count++;
    if (bestSeasonController.text.trim().isNotEmpty) count++;
    count += selectedServices.values.where((v) => v).length;
    return count;
  }

  @override
  void dispose() {
    nameController.dispose();
    areaController.dispose();
    landscapeController.dispose();
    bestSeasonController.dispose();
    super.dispose();
  }

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
                    // Canonicalize on the way in too — if selectedGovernorate
                    // was ever set from somewhere outside this screen using a
                    // raw/aliased value (e.g. "Dohfar"), this still matches
                    // the canonical entry in _governorateItems instead of
                    // crashing with "value isn't in items".
                    value: selectedGovernorate == null
                        ? null
                        : _canonicalGovernorate(selectedGovernorate!),
                    items: _governorateItems,
                    displayBuilder: (v) => governoratesEnglishToArabic[v] ?? v,
                    onChanged: (v) => setState(() =>
                    selectedGovernorate = v == null ? null : _canonicalGovernorate(v)),
                  ),
                  const SizedBox(height: 12),

                  // State selector
                  _buildDropdownCard(
                    icon: Icons.location_city_rounded,
                    hint: getTextByKey(key: TranslationKey.keySelectState),
                    value: selectedState == null
                        ? null
                        : _canonicalState(selectedState!),
                    items: _stateItems,
                    displayBuilder: (v) => statesEnglishToArabicFilter[v] ?? v,
                    onChanged: (v) => setState(() =>
                    selectedState = v == null ? null : _canonicalState(v)),
                  ),
                  // const SizedBox(height: 12),
                  //
                  // // Area (free text — no value list provided yet)
                  // _buildTextFieldCard(
                  //   context: context,
                  //   icon: Icons.terrain_outlined,
                  //   hint: getTextByKey(key: TranslationKey.keyArea),
                  //   controller: areaController,
                  // ),

                  const SizedBox(height: 28),

                  // Chalet type — 3 fixed options (matches the owner web
                  // panel's actual chip picker exactly: Chalet/Resort/Hut,
                  // see ChaletCharacteristicsSection.jsx), so a single tap
                  // on a chip beats opening a dropdown menu.
                  _sectionTitle(context, TranslationKey.keyChaletType),
                  const SizedBox(height: 10),
                  _buildChipGroupCard(
                    context: context,
                    value: selectedChaletType,
                    items: chaletTypeEnglishToArabic.keys.toList(),
                    displayBuilder: (v) => chaletTypeEnglishToArabic[v] ?? v,
                    onChanged: (v) => setState(() => selectedChaletType = v),
                  ),

                  const SizedBox(height: 28),

                  // Dates
                  _sectionTitle(context, TranslationKey.keySelectDates),
                  const SizedBox(height: 10),
                  _buildDateRangeCard(context),

                  const SizedBox(height: 28),

                  // Price range — matches the web filter bar's min/max
                  // price fields, which were previously not exposed here at
                  // all (the slider UI existed but was never shown, so
                  // guests had no way to narrow by price on mobile).
                  _sectionTitle(context, TranslationKey.keySelectPriceRange),
                  const SizedBox(height: 10),
                  _buildPriceRangeCard(context),

                  const SizedBox(height: 28),

                  // Rooms & capacity — chip pills instead of dropdowns so
                  // every option (1-5+) is visible and pickable in one tap.
                  // Matches the web "More filters" popup's capacity/
                  // bedrooms/bathrooms/livingRooms number fields.
                  _sectionTitle(context, TranslationKey.keyCapacity),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildLabeledChipGroup(
                          context: context,
                          label: getTextByKey(key: TranslationKey.keyCapacity),
                          value: selectedCapacity,
                          items: _roomCountOptions,
                          onChanged: (v) =>
                              setState(() => selectedCapacity = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLabeledChipGroup(
                          context: context,
                          label: getTextByKey(key: TranslationKey.keyBedrooms),
                          value: selectedBedrooms,
                          items: _roomCountOptions,
                          onChanged: (v) =>
                              setState(() => selectedBedrooms = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildLabeledChipGroup(
                          context: context,
                          label:
                          getTextByKey(key: TranslationKey.keyBathrooms),
                          value: selectedBathrooms,
                          items: _roomCountOptions,
                          onChanged: (v) =>
                              setState(() => selectedBathrooms = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLabeledChipGroup(
                          context: context,
                          label:
                          getTextByKey(key: TranslationKey.keyLivingRooms),
                          value: selectedLivingRooms,
                          items: _roomCountOptions,
                          onChanged: (v) =>
                              setState(() => selectedLivingRooms = v),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Rating and landscape/bestSeason/name are intentionally
                  // NOT shown here — matches the website's FilterBar.jsx,
                  // which dropped `rate` entirely and excludes landscape/
                  // bestSeason because the chaletowner mobile app and web
                  // owner panel store them in two different, mutually
                  // unmatchable formats (see buildFilters() comment in
                  // FilterBar.jsx). Re-enable only if that's fixed first.

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
                      // Greys itself out (via the disabled onPressed) when
                      // there's nothing to reset, instead of always looking
                      // active.
                      onPressed:
                      _activeFilterCount > 0 ? _resetFilters : null,
                      icon: Icon(Icons.refresh_rounded,
                          color: _activeFilterCount > 0
                              ? Colors.grey.shade500
                              : Colors.grey.shade300),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ActionBtn(
                            onPressed: _applyFilters,
                            btnTitle:
                            getTextByKey(key: TranslationKey.keyApplyFilters),
                            btnColor: primaryColor,
                          ),
                          // Live count of active filters, so the user
                          // knows what they're about to apply before
                          // tapping.
                          if (_activeFilterCount > 0)
                            Positioned(
                              top: -6,
                              right: -6,
                              child: Container(
                                constraints: const BoxConstraints(
                                    minWidth: 20, minHeight: 20),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: Text(
                                  '$_activeFilterCount',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
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

  Widget _fieldLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyles.textStyleBody(context).copyWith(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  /// Tappable header for the collapsible "more filters" section — the
  /// chevron rotates in place instead of the section just popping open.
  Widget _buildMoreFiltersToggle(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _showMoreFilters = !_showMoreFilters),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionTitle(context, TranslationKey.keyMoreFilters),
          AnimatedRotation(
            turns: _showMoreFilters ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// Shared card shell used by every filter row (dropdown, text field,
  /// date range, rating, chips) so the whole screen stays visually
  /// consistent.
  Widget _cardShell({required Widget child, EdgeInsetsGeometry? padding}) {
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
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14),
      child: child,
    );
  }

  /// Reusable dropdown card. `displayBuilder` controls only what text is
  /// shown; `value` / `onChanged` always carry the raw English API key.
  /// Kept for fields with long lists (governorate/state) where chips
  /// would take over the whole screen.
  Widget _buildDropdownCard({
    required IconData icon,
    required String hint,
    required String? value,
    required List<String> items,
    required String Function(String) displayBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    return _cardShell(
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(hint,
                    style: TextStyles.textStyleBody(context),
                    overflow: TextOverflow.ellipsis),
                // Defensive: if, despite canonicalizing above, `value`
                // still isn't present in `items` for some unforeseen
                // reason, fall back to null instead of letting
                // DropdownButton throw "There should be exactly one
                // item with [DropdownButton]'s value".
                value: (value != null && items.contains(value)) ? value : null,
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

  /// Tappable pill/chip selector — one tap to select, one tap again to
  /// clear. Used for small fixed option sets (chaletType, room counts)
  /// where a dropdown menu is an unnecessary extra step.
  Widget _buildChipGroupCard({
    required BuildContext context,
    required String? value,
    required List<String> items,
    required String Function(String) displayBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    return _cardShell(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((v) {
          final bool selected = value == v;
          return GestureDetector(
            onTap: () => onChanged(selected ? null : v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? primaryColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                  selected ? primaryColor : Colors.grey.withOpacity(0.15),
                ),
              ),
              child: Text(
                displayBuilder(v),
                style: TextStyles.textStyleBody(context).copyWith(
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// A small label above a chip group card — used for the 2-column room
  /// count fields (capacity/bedrooms/bathrooms/livingRooms) where the
  /// card alone wouldn't say what it represents.
  Widget _buildLabeledChipGroup({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, label),
        const SizedBox(height: 6),
        _buildChipGroupCard(
          context: context,
          value: value,
          items: items,
          displayBuilder: (v) => v,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Plain search-style text field card — used for filters that don't have
  /// a fixed value list yet (name, area, landscape, bestSeason).
  Widget _buildTextFieldCard({
    required BuildContext context,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
  }) {
    return _cardShell(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyles.textStyleBody(context),
              // Rebuild on every keystroke so the clear (x) button and
              // the active-filter badge/count stay in sync as the user
              // types, instead of only updating on the next unrelated
              // setState.
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: hint,
                hintStyle: TextStyles.textStyleBody(context),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => controller.clear()),
              child: Icon(Icons.close_rounded,
                  size: 16, color: Colors.grey.shade400),
            ),
        ],
      ),
    );
  }

  /// Dropdown-styled card that, instead of opening a DropdownButton menu,
  /// opens a modal bottom sheet containing CalendarDatePicker2. Shows the
  /// selected range once picked, otherwise the hint text.
  Widget _buildDateRangeCard(BuildContext context) {
    final hasRange = dates != null &&
        dates!.isNotEmpty &&
        dates!.first != null;

    final String label = hasRange
        ? '${formatDate(dates!.first!)}'
        '${dates!.length > 1 && dates![1] != null ? '  -  ${formatDate(dates![1]!)}' : ''}'
        : getTextByKey(key: TranslationKey.keySelectDates);

    return GestureDetector(
      onTap: () => _openDateRangeSheet(context),
      child: _cardShell(
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  label,
                  style: hasRange
                      ? TextStyles.textStyleBody(context)
                      : TextStyles.textStyleBody(context)
                      .copyWith(color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (hasRange)
              GestureDetector(
                onTap: () => setState(() => dates = null),
                child: Icon(Icons.close_rounded,
                    size: 16, color: Colors.grey.shade400),
              )
            else
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  void _openDateRangeSheet(BuildContext context) {
    List<DateTime?>? tempDates = dates == null ? null : List.of(dates!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Text(
                    getTextByKey(key: TranslationKey.keySelectDates),
                    style: TextStyles.textStyleTitle(sheetContext).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CalendarDatePicker2(
                    config: CalendarDatePicker2Config(
                      todayTextStyle: TextStyles.textStyleBody(sheetContext),
                      calendarType: CalendarDatePicker2Type.range,
                      firstDate: currentDate.add(const Duration(days: 1)),
                      lastDate: currentDate
                          .add(const Duration(days: 1))
                          .add(const Duration(days: 4 * 30)),
                      selectableDayPredicate: (value) {
                        if (formatDate(value) == formatDate(DateTime.now())) {
                          return false;
                        } else {
                          return true;
                        }
                      },
                    ),
                    value: tempDates ?? const [],
                    onValueChanged: (datesValue) {
                      setSheetState(() => tempDates = datesValue);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() => tempDates = null);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Icon(Icons.refresh_rounded,
                              color: Colors.grey.shade500),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: ActionBtn(
                          onPressed: () {
                            setState(() => dates = tempDates);
                            Navigator.pop(sheetContext);
                          },
                          btnTitle:
                          getTextByKey(key: TranslationKey.keyConfirm),
                          btnColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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

  /// Tappable 1-5 star row for the minimum-rating filter. Tapping the
  /// currently-selected star again clears the filter back to "any rating".
  Widget _buildRatingCard(BuildContext context) {
    return _cardShell(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...List.generate(5, (index) {
            final starValue = index + 1;
            final bool filled = starValue <= selectedRate;
            return GestureDetector(
              onTap: () => setState(() {
                selectedRate = (selectedRate == starValue) ? 0 : starValue;
              }),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                size: 28,
                color: filled ? primaryColor : Colors.grey.shade400,
              ),
            );
          }),
          if (selectedRate > 0)
            Text(
              '$selectedRate '
                  '${selectedRate == 1 ? getTextByKey(key: TranslationKey.keyStar) : getTextByKey(key: TranslationKey.keyStars)}',
              style: TextStyles.textStyleBody(context).copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
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
      selectedPriceRange = _defaultPriceRange;
      selectedServices.updateAll((k, v) => false);

      selectedChaletType = null;
      selectedCapacity = null;
      selectedBedrooms = null;
      selectedBathrooms = null;
      selectedLivingRooms = null;
      selectedRate = 0;
      dates = null;

      nameController.clear();
      areaController.clear();
      landscapeController.clear();
      bestSeasonController.clear();
    });
  }

  void _applyFilters() {
    final DateTime? startDate =
    (dates != null && dates!.isNotEmpty) ? dates![0] : null;
    final DateTime? endDate =
    (dates != null && dates!.length > 1) ? dates![1] : null;

    final filterBody = {
      "serviesList": selectedServices.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
      "fromPrice": selectedPriceRange.start.toInt(),
      "toPrice": selectedPriceRange.end.toInt(),
      "state": selectedState,
      "governorate": selectedGovernorate,
      "name": nameController.text.trim().isEmpty
          ? null
          : nameController.text.trim(),
      "rate": selectedRate,
      "chaletType": selectedChaletType,
      "capacity": selectedCapacity,
      "bedrooms": selectedBedrooms,
      "landscape": landscapeController.text.trim().isEmpty
          ? null
          : landscapeController.text.trim(),
      "bathrooms": selectedBathrooms,
      "livingRooms": selectedLivingRooms,
      "bestSeason": bestSeasonController.text.trim().isEmpty
          ? null
          : bestSeasonController.text.trim(),
      "area": areaController.text.trim().isEmpty
          ? null
          : areaController.text.trim(),
      // The API's `startDate`/`endDate` are non-nullable DateTime on the
      // server side — sending JSON `null` throws "The JSON value could
      // not be converted to System.DateTime" (400). So instead of always
      // including the key with a possibly-null value, only add it when a
      // date was actually picked; when no range is selected, the key is
      // left out of the body entirely.
      if (startDate != null) "startDate": startDate.toIso8601String(),
      if (endDate != null) "endDate": endDate.toIso8601String(),
    };

    // Dispatches the dedicated filter event (see chalets_bloc.dart) so
    // ChaletsByFilterPage gets its own Loading/Loaded/Error*Filter*
    // states, instead of sharing LoadedChaletsState with the home feed.
    BlocProvider.of<ChaletsBloc>(context).add(GetAllChaletsFilterEvent(
      pageNumber: CommonFunctions.pageNumberFillterChalets,
      body: {
        "page": 1,
        "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
        ...filterBody,
      },
    ));

    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: ChaletsByFilterPage(filterBody: filterBody),
      withNavBar: false,
    );
  }
}