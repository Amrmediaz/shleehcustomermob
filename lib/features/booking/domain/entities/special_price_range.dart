/// فترة سعر خاص/مخفّض راجعة من الـ APIs بتاعة الأسعار الخاصة.
class SpecialPriceRange {
  final DateTime start;
  final DateTime end;
  final double price;
  final int type;

  SpecialPriceRange({
    required this.start,
    required this.end,
    required this.price,
    required this.type,
  });

  bool covers(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }
}

/// بيحوّل نص التاريخ بصيغة `dd/MM/yyyy` زي ما بيرجعه الـ API الخاص بالأسعار.
DateTime? parseApiDate(String? value) {
  if (value == null || value.isEmpty) return null;
  final parts = value.split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

const Map<String, String> _easternArabicDigits = {
  '0': '٠',
  '1': '١',
  '2': '٢',
  '3': '٣',
  '4': '٤',
  '5': '٥',
  '6': '٦',
  '7': '٧',
  '8': '٨',
  '9': '٩',
};

/// بيحوّل الأرقام الإنجليزية (0-9) في أي نص لأرقام عربية (٠-٩).
// String toEasternArabicDigits(String input) {
//   final buffer = StringBuffer();
//   for (final char in input.split('')) {
//     buffer.write(_easternArabicDigits[char] ?? char);
//   }
//   return buffer.toString();
// }

/// بيصيغ التاريخ بشكل `yyyy/MM/dd` بأرقام عربية (مثال: ٢٠٢٦/٠٨/٠٥).
String formatDateYyyyMmDd(DateTime d) {
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return ('${d.year}/$month/$day');
}