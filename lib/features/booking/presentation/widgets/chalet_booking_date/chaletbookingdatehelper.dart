import 'dart:convert';

import 'package:easy_localization/easy_localization.dart' as easy;

/// Result of converting a selected date range into a JSON payload the
/// backend expects, plus the per-day price-calculation list used by the UI.
class DateRangeConversionResult {
  final String jsonPayload;
  final List<Map<String, dynamic>> bookingDaysCalculatePrice;

  const DateRangeConversionResult({
    required this.jsonPayload,
    required this.bookingDaysCalculatePrice,
  });
}

/// Pure helper functions for turning a selected [DateTime] range into the
/// data shapes the booking flow needs (JSON for price calc, formatted list
/// for the actual booking request, and booked-date collision checks).
///
/// Extracted from ChaletBookingDateWidget so the date/JSON logic can be
/// unit-tested without needing a Flutter widget tree.
// NOTE: this is only the `ChaletBookingDateHelper` class body, fixed to
// count nights the standard hotel way (checkout - checkin), not inclusive
// of both ends. Paste this over the existing class in your real
// chaletbookingdatehelper.dart - keep your existing imports and the
// `_DateSpan` / `DateRangeConversionResult` class definitions as they are,
// I don't have those in this conversation so I'm not reproducing them here.

class ChaletBookingDateHelper {
  const ChaletBookingDateHelper._();

  /// Returns the effective start/end pair, treating a single selected day
  /// as a 1-day range (start == end).
  static _DateSpan resolveRange(List<DateTime?> dateRange) {
    if (dateRange.isEmpty || dateRange.any((date) => date == null)) {
      throw ArgumentError('Invalid date range');
    }
    final DateTime start = dateRange[0]!;
    final DateTime end = dateRange.length > 1 ? dateRange[1]! : dateRange[0]!;
    return _DateSpan(start, end);
  }

  /// The exclusive upper bound to loop up to when building day-by-day
  /// lists.
  ///
  /// Hotel/chalet convention: checkin -> checkout spans N nights, where
  /// N = checkout - checkin (the checkout day itself is NOT an occupied
  /// night - e.g. 25 -> 26 is a single night, not two days). A single
  /// tapped day (start == end, "book one day") still counts as one day.
  static DateTime _exclusiveLoopEnd(_DateSpan span) {
    return span.start.isAtSameMomentAs(span.end)
        ? span.end.add(const Duration(days: 1))
        : span.end;
  }

  /// Builds the JSON body sent to the "calculate total price" endpoint,
  /// along with the day-by-day list used to render prices in the UI.
  static DateRangeConversionResult convertDateRangeToJsonString({
    required List<DateTime?> dateRange,
    required int buildingId,
    required bool isChalet,
    required bool isFullDay,
  }) {
    final _DateSpan span = resolveRange(dateRange);
    final DateTime loopEnd = _exclusiveLoopEnd(span);

    final List<Map<String, dynamic>> bookingDaysCalculatePrice = [];
    for (DateTime date = span.start;
    date.isBefore(loopEnd);
    date = date.add(const Duration(days: 1))) {
      bookingDaysCalculatePrice.add({
        'day': date.toIso8601String(),
        'fullday': isFullDay,
      });
    }

    final dynamic jsonData = {
      isChalet ? 'buldingId' : 'flatID': buildingId,
      'bookingDays': bookingDaysCalculatePrice,
    };

    return DateRangeConversionResult(
      jsonPayload: jsonEncode(jsonData),
      bookingDaysCalculatePrice: bookingDaysCalculatePrice,
    );
  }

  /// Builds the day-by-day list ("dd/MM/yyyy" + isFullDay) sent to the
  /// actual "book chalet" endpoint.
  static List<Map<String, dynamic>> buildBookedDaysPayload({
    required List<DateTime?> dateRange,
    required bool isFullDay,
  }) {
    final _DateSpan span = resolveRange(dateRange);
    final DateTime loopEnd = _exclusiveLoopEnd(span);
    final easy.DateFormat dateFormatter = easy.DateFormat('dd/MM/yyyy', 'en');

    final List<Map<String, dynamic>> bookedNewlyDays = [];
    for (DateTime date = span.start;
    date.isBefore(loopEnd);
    date = date.add(const Duration(days: 1))) {
      bookedNewlyDays.add({
        'day': dateFormatter.format(date),
        'isFullDay': isFullDay,
      });
    }
    return bookedNewlyDays;
  }

  /// Returns false if any already-booked date falls strictly between
  /// [startDate] and [endDate] (exclusive), meaning the chosen range
  /// collides with an existing booking.
  ///
  /// Unchanged: the calendar's `selectableDayPredicate` already blocks
  /// picking a booked day as the start/end point itself, so this only
  /// needs to check the days strictly in between - which stays correct
  /// under the new nights-based counting above.
  static bool isDateRangeAvailable({
    required DateTime startDate,
    required DateTime endDate,
    required List<String> bookedDates,
  }) {
    for (final dateString in bookedDates) {
      final parts = dateString.split('/');
      if (parts.length != 3) continue;

      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) continue;

      final bookedDate = DateTime(year, month, day);
      if (bookedDate.isAfter(startDate) && bookedDate.isBefore(endDate)) {
        return false;
      }
    }
    return true;
  }
}

/// Tiny value holder for a resolved start/end date pair.
class _DateSpan {
  final DateTime start;
  final DateTime end;
  const _DateSpan(this.start, this.end);
}