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
import '../../bloc/chalets/chalets_bloc.dart';
import '../../pages/chalets_by_filter_page.dart';

class _PriceBucket {
  final String label;
  final int from;
  final int to;
  const _PriceBucket(this.label, this.from, this.to);
}

const List<_PriceBucket> _chaletPriceBuckets = [
  _PriceBucket('حتى 50', 20, 50),
  _PriceBucket('50 - 100', 50, 100),
  _PriceBucket('100 - 150', 100, 150),
  _PriceBucket('أكثر من 150', 150, 200),
];

/// One-tap filter chips for the main chalets list — location / dates /
/// price. Picking a value from any chip's popup just records the choice
/// locally (no navigation yet); an "Apply" button appears once at least one
/// is set, and only then does this dispatch the *same* GetAllChaletsFilterEvent
/// + ChaletsByFilterPage navigation the full filter form already uses, so
/// results rendering is guaranteed to work exactly the same way. The full
/// filter page (with services, ratings, etc.) is still reachable via the
/// existing Filter button for anything not covered here.
class ChaletQuickFilters extends StatefulWidget {
  const ChaletQuickFilters({Key? key}) : super(key: key);

  @override
  State<ChaletQuickFilters> createState() => _ChaletQuickFiltersState();
}

class _ChaletQuickFiltersState extends State<ChaletQuickFilters> {
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
          options: _chaletPriceBuckets
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
    CommonFunctions.pageNumberFillterChalets = 1;

    final filterBody = <String, dynamic>{
      if (_selectedState != null) "state": _selectedState,
      if (_selectedPrice != null) "fromPrice": _selectedPrice!.from,
      if (_selectedPrice != null) "toPrice": _selectedPrice!.to,
      if (_startDate != null && _endDate != null)
        "startDate": "$_startDate".replaceAll(" ", "T"),
      if (_startDate != null && _endDate != null)
        "endDate": "$_endDate".replaceAll(" ", "T"),
    };

    // Always the "normal" filter event (never GetAllChaletsFilterDateEvent)
    // — it's the only one guaranteed to land on LoadedChaletsFilterState /
    // ErrorChaletsFilterState, which is what ChaletsByFilterPage actually
    // knows how to render, regardless of whether the body has dates in it.
    // This exactly mirrors what the full filter form's Apply button does.
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

  Widget _rowDivider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
      );

  @override
  Widget build(BuildContext context) {
    // This is now only used inside the quick-actions bottom sheet (see
    // ChaletsPageWidget), not squeezed into the page header anymore — so it
    // can use the sheet's full width as a proper vertical list (icon,
    // label, value, chevron) with hairline dividers, instead of three
    // cramped side-by-side cards.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuickFilterSegment(
          icon: Icons.pin_drop_rounded,
          overline: 'الموقع',
          value: _selectedState != null
              ? (statesEnglishToArabicFilter[_selectedState] ?? _selectedState!)
              : 'أي موقع',
          isActive: _selectedState != null,
          onTap: _pickLocation,
          onClear: () => setState(() => _selectedState = null),
        ),
        _rowDivider(),
        _QuickFilterSegment(
          icon: Icons.calendar_today_rounded,
          overline: 'التاريخ',
          value: (_startDate != null && _endDate != null)
              ? '${formatDate(_startDate!)} - ${formatDate(_endDate!)}'
              : 'أي وقت',
          isActive: _startDate != null && _endDate != null,
          onTap: _pickDates,
          onClear: () => setState(() {
            _startDate = null;
            _endDate = null;
          }),
        ),
        _rowDivider(),
        _QuickFilterSegment(
          icon: Icons.sell_rounded,
          overline: 'السعر',
          value: _selectedPrice?.label ?? 'أي سعر',
          isActive: _selectedPrice != null,
          onTap: _pickPrice,
          onClear: () => setState(() => _selectedPrice = null),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: _hasSelection
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _applyQuickFilters,
                      icon: const Icon(Icons.search_rounded, size: 19, color: Colors.white),
                      label: Text(
                        getTextByKey(key: TranslationKey.keyApplyFilters),
                        style: TextStyles.textStyleButton(context).copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

/// One segment ("الموقع" / "التاريخ" / "السعر") of the unified search
/// card. All three share identical padding/typography/icon treatment so
/// the row reads as one coherent control instead of three differently
/// shaped buttons improvising their own style.
class _QuickFilterSegment extends StatefulWidget {
  final IconData icon;
  final String overline;
  final String value;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _QuickFilterSegment({
    Key? key,
    required this.icon,
    required this.overline,
    required this.value,
    required this.isActive,
    required this.onTap,
    required this.onClear,
  }) : super(key: key);

  @override
  State<_QuickFilterSegment> createState() => _QuickFilterSegmentState();
}

class _QuickFilterSegmentState extends State<_QuickFilterSegment> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    // Full-width list row (icon, overline+value, chevron/clear) instead of
    // a small standalone card — this only ever appears stacked inside the
    // quick-actions sheet now, so it reads better as a proper list item
    // (like a settings row) than as a squeezed chip.
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? primaryColor : primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 18, color: isActive ? Colors.white : primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.overline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? primaryColor : Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                GestureDetector(
                  onTap: widget.onClear,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: Icon(Icons.close_rounded, size: 14, color: Colors.grey.shade600),
                  ),
                )
              else
                // The app is always RTL, so this uses the already-left-
                // pointing icon directly (Icon has no matchTextDirection
                // param to mirror a "forward" arrow automatically).
                Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade300, size: 14),
            ],
          ),
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

/// Simple single-choice bottom sheet — used for both the location and
/// price quick filters. Tapping an option pops it immediately and selects
/// it; clearing a selection is done via the chip's own "x" button, not
/// from inside this sheet.
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle — same convention as the app's other bottom
            // sheets (see CommonFunctions.showBottomDialog).
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                title,
                style: TextStyles.textStyleTitle(context).copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option.value == selectedValue;
                  return Material(
                    color: isSelected ? primaryColor.withOpacity(0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      // Always pop the tapped value (never null) — dismissing
                      // the sheet by tapping the scrim also resolves with
                      // null, so treating null here as "clear" would wipe an
                      // existing selection just by tapping outside. Clearing
                      // is handled by the chip's own "x" button instead.
                      onTap: () => Navigator.pop(context, option.value),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                              size: 19,
                              color: isSelected ? primaryColor : Colors.grey.shade300,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option.label,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 14,
                                  color: isSelected ? primaryColor : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
