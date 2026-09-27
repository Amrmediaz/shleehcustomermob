import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/styles/text/text_style.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/action_btn.dart';
import '../../bloc/buildings/buildings_bloc.dart';
import '../../pages/buildings_by_filter_page.dart';

class _PriceBucket {
  final String label;
  final int from;
  final int to;
  const _PriceBucket(this.label, this.from, this.to);
}

const List<_PriceBucket> _buildingPriceBuckets = [
  _PriceBucket('حتى 50', 20, 50),
  _PriceBucket('50 - 100', 50, 100),
  _PriceBucket('100 - 150', 100, 150),
  _PriceBucket('أكثر من 150', 150, 200),
];

/// Same idea as ChaletQuickFilters, mirrored for the buildings list.
/// Buildings only have one event type (GetAllBuildingsEvent) that always
/// resolves to LoadedBuildingsState/ErrorBuildingsState regardless of body
/// shape, so combining location/dates/price into one body here is safe.
class BuildingQuickFilters extends StatefulWidget {
  const BuildingQuickFilters({Key? key}) : super(key: key);

  @override
  State<BuildingQuickFilters> createState() => _BuildingQuickFiltersState();
}

class _BuildingQuickFiltersState extends State<BuildingQuickFilters> {
  String? _selectedState;
  _PriceBucket? _selectedPrice;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _hasSelection =>
      _selectedState != null || _selectedPrice != null || (_startDate != null && _endDate != null);

  Future<void> _pickLocation() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _QuickFilterSheet<String>(
          title: 'اختر الموقع',
          selectedValue: _selectedState,
          options: states
              .map((s) => _SheetOption(value: s, label: statesEnglishToArabicFilter[s] ?? s))
              .toList(),
        );
      },
    );
    // null means the sheet was dismissed without a tap — leave the current
    // selection untouched. Clearing happens via the chip's own "x" button.
    if (result != null && mounted) {
      setState(() => _selectedState = result);
    }
  }

  Future<void> _pickPrice() async {
    final result = await showModalBottomSheet<_PriceBucket>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _QuickFilterSheet<_PriceBucket>(
          title: 'السعر (ريال عماني)',
          selectedValue: _selectedPrice,
          options: _buildingPriceBuckets
              .map((b) => _SheetOption(value: b, label: b.label))
              .toList(),
        );
      },
    );
    if (result != null && mounted) {
      setState(() => _selectedPrice = result);
    }
  }

  Future<void> _pickDates() async {
    List<DateTime?> tempDates = (_startDate != null && _endDate != null)
        ? [_startDate, _endDate]
        : [];
    final currentDate = DateTime.now();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getTextByKey(key: TranslationKey.keyCheckDateAvailability),
                    style: TextStyles.textStyleTitle(sheetContext),
                  ),
                  const SizedBox(height: 8),
                  CalendarDatePicker2(
                    config: CalendarDatePicker2Config(
                      todayTextStyle: TextStyles.textStyleBody(sheetContext),
                      calendarType: CalendarDatePicker2Type.range,
                      firstDate: currentDate.add(const Duration(days: 1)),
                      lastDate: currentDate.add(const Duration(days: 1 + 4 * 30)),
                    ),
                    value: tempDates,
                    onValueChanged: (value) => setSheetState(() => tempDates = value),
                  ),
                  const SizedBox(height: 8),
                  ActionBtn(
                    onPressed: () {
                      if (tempDates.length < 2 || tempDates[0] == null || tempDates[1] == null) {
                        return;
                      }
                      Navigator.pop(sheetContext, true);
                    },
                    btnTitle: getTextByKey(key: TranslationKey.keyApplyFilters),
                    btnColor: primaryColor,
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (confirmed == true && tempDates.length >= 2 && mounted) {
      setState(() {
        _startDate = tempDates[0];
        _endDate = tempDates[1];
      });
    }
  }

  void _applyQuickFilters() {
    CommonFunctions.pageNumberbuildings = 1;

    final filterBody = <String, dynamic>{
      if (_selectedState != null) "state": _selectedState,
      if (_selectedPrice != null) "fromPrice": _selectedPrice!.from,
      if (_selectedPrice != null) "toPrice": _selectedPrice!.to,
      if (_startDate != null && _endDate != null)
        "startDate": "$_startDate".replaceAll(" ", "T"),
      if (_startDate != null && _endDate != null)
        "endDate": "$_endDate".replaceAll(" ", "T"),
    };

    BlocProvider.of<BuildingsBloc>(context).add(GetAllBuildingsEvent(
      pageNumber: CommonFunctions.pageNumberbuildings,
      body: {
        "page": 1,
        "pageSize": PAGE_SIZE_BUILDINGS_PAGINATION,
        "heightolow": 1,
        "rateheightolow": 0,
        ...filterBody,
      },
    ));

    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: BuildingsByFilterPage(filterBody: filterBody),
      withNavBar: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickFilterChip(
                icon: Icons.pin_drop_rounded,
                label: _selectedState != null
                    ? (statesEnglishToArabicFilter[_selectedState] ?? _selectedState!)
                    : 'الموقع',
                isActive: _selectedState != null,
                onTap: _pickLocation,
                onClear: () => setState(() => _selectedState = null),
              ),
              const SizedBox(width: 8),
              _QuickFilterChip(
                icon: Icons.calendar_today_rounded,
                label: (_startDate != null && _endDate != null)
                    ? '${formatDate(_startDate!)} - ${formatDate(_endDate!)}'
                    : 'التاريخ',
                isActive: _startDate != null && _endDate != null,
                onTap: _pickDates,
                onClear: () => setState(() {
                  _startDate = null;
                  _endDate = null;
                }),
              ),
              const SizedBox(width: 8),
              _QuickFilterChip(
                icon: Icons.sell_rounded,
                label: _selectedPrice?.label ?? 'السعر',
                isActive: _selectedPrice != null,
                onTap: _pickPrice,
                onClear: () => setState(() => _selectedPrice = null),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: _hasSelection
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyQuickFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        getTextByKey(key: TranslationKey.keyApplyFilters),
                        style: TextStyles.textStyleButton(context).copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _QuickFilterChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? primaryColor : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isActive ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 110),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetOption<T> {
  final T value;
  final String label;
  const _SheetOption({required this.value, required this.label});
}

/// Simple single-choice bottom sheet — tapping an option pops it
/// immediately and selects it; clearing a selection is done via the
/// chip's own "x" button, not from inside this sheet.
class _QuickFilterSheet<T> extends StatelessWidget {
  final String title;
  final T? selectedValue;
  final List<_SheetOption<T>> options;

  const _QuickFilterSheet({
    Key? key,
    required this.title,
    required this.selectedValue,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(title, style: TextStyles.textStyleTitle(context)),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: options.map((option) {
                  final isSelected = option.value == selectedValue;
                  return ListTile(
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? primaryColor : Colors.black87,
                      ),
                    ),
                    trailing: isSelected ? Icon(Icons.check_rounded, color: primaryColor) : null,
                    // Always pop the tapped value (never null) — dismissing
                    // the sheet by tapping the scrim also resolves with
                    // null, so treating null here as "clear" would wipe an
                    // existing selection just by tapping outside. Clearing
                    // is handled by the chip's own "x" button instead.
                    onTap: () => Navigator.pop(context, option.value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
