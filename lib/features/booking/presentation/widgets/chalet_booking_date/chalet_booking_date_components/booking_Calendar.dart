import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';

import '../../../../domain/entities/special_price_range.dart';
import '../chaletbookingdatehelper.dart';

/// RTL range calendar for picking booking dates, with special/discounted
/// price days marked with a small amber dot.
class BookingCalendar extends StatelessWidget {
  final List<DateTime?> value;
  final List<String> bookedDates;
  final List<SpecialPriceRange> specialPrices;
  final DateTime currentDate;
  final bool isFullDay;
  final ValueChanged<List<DateTime?>> onValueChanged;

  const BookingCalendar({
    Key? key,
    required this.value,
    required this.bookedDates,
    required this.specialPrices,
    required this.currentDate,
    required this.isFullDay,
    required this.onValueChanged,
  }) : super(key: key);

  SpecialPriceRange? _specialPriceFor(DateTime date) {
    for (final range in specialPrices) {
      if (range.covers(date)) return range;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CalendarDatePicker2(
        config: CalendarDatePicker2Config(
          selectedYearTextStyle: TextStyles.textStyleBody(context),
          weekdayLabelTextStyle: TextStyles.textStyleBody(context),
          dayTextStyle: TextStyles.textStyleBody(context),
          todayTextStyle: TextStyles.textStyleBody(context),
          disabledDayTextStyle:
          TextStyles.textStyleBody(context).copyWith(color: Colors.red.shade200),
          selectedDayTextStyle: TextStyles.textStyleBody(context).copyWith(color: Colors.white),
          yearTextStyle: TextStyles.textStyleBody(context),
          calendarType: isFullDay
              ? CalendarDatePicker2Type.range
              : CalendarDatePicker2Type.single,
          firstDate: currentDate,
          lastDate: currentDate.add(const Duration(days: 1)).add(const Duration(days: 4 * 30)),
          selectableDayPredicate: (day) {
            final isBooked = bookedDates.contains(getBookedDatesWithCalendarFormat(day));
            if (!isBooked) return true;

            // A booked day was previously untappable outright, which broke
            // a very normal case: chalet is free the night of the 23rd but
            // another guest's stay starts the night of the 24th (24 shows
            // up in bookedDates) — that guest doesn't occupy the 24th until
            // that night, so a checkout on the morning of the 24th (range
            // 23 -> 24) is perfectly valid and shouldn't be blocked. Only
            // block a booked day from being the *check-in* date (that
            // night really is occupied) or from single-day ("نص يوم")
            // picks, which have no separate checkout day to fall back on.
            if (!isFullDay) return false;
            final DateTime? start = value.isNotEmpty ? value.first : null;
            if (start == null) return false;
            if (!day.isAfter(start)) return false;

            // Only the *first* booked day reachable from `start` is a
            // valid checkout — every night the stay actually needs
            // (start .. day-1) must be free. Without this check, tapping
            // one booked day right after the start used to make every
            // later booked day look tappable too (they all satisfy
            // "isAfter(start)"), even ones that are unreachable because an
            // earlier night in between is already taken — confusing, since
            // most of those would just get rejected after the fact. This
            // is the exact same "any booked night strictly inside the
            // range" check used once a full range is confirmed, just run
            // early so the calendar only ever offers checkout days that
            // will actually work.
            return ChaletBookingDateHelper.isDateRangeAvailable(
              startDate: start,
              endDate: day,
              bookedDates: bookedDates,
            );
          },
          // Marks days that have a special/discounted price with a small
          // amber dot, so the user can spot them at a glance.
          dayBuilder: ({
            required DateTime date,
            TextStyle? textStyle,
            BoxDecoration? decoration,
            bool? isSelected,
            bool? isDisabled,
            bool? isToday,
          }) {
            final special = _specialPriceFor(date);
            if (special == null) return null;

            final selected = isSelected ?? false;
            final disabled = isDisabled ?? false;

            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: selected ? primaryColor : Colors.amber.shade50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: disabled ? Colors.red.shade100 : Colors.amber.shade400,
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${date.day}',
                    style: (textStyle ?? const TextStyle()).copyWith(
                      color: disabled
                          ? Colors.red.shade200
                          : (selected ? Colors.white : Colors.amber.shade900),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!disabled)
                    Container(
                      margin: const EdgeInsets.only(top: 1),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.amber.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        value: value,
        onValueChanged: onValueChanged,
      ),
    );
  }
}