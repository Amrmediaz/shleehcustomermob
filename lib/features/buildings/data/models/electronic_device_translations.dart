/// Maps the English `serviceName` values returned by the API
/// (electronic_devices[].serviceName) to their Arabic display text.
///
/// Lookup is case-insensitive and trims whitespace. Anything not found in
/// the map falls back to the original value from the API, so new/unlisted
/// devices still show something instead of breaking.
class ElectronicDeviceTranslations {
  const ElectronicDeviceTranslations._();

  static final Map<String, String> _arabicNames = {
    'microwave': 'ميكروويف',
    'smart tv': 'شاشة تلفزيون ذكية',
    'tv': 'تلفزيون',
    'television': 'تلفزيون',
    'air conditioner': 'مكيف هواء',
    'ac': 'مكيف هواء',
    'refrigerator': 'ثلاجة',
    'fridge': 'ثلاجة',
    'washing machine': 'غسالة ملابس',
    'iron': 'مكواة',
    'electric oven': 'فرن كهربائي',
    'oven': 'فرن',
    'water kettle': 'غلاية مياه',
    'kettle': 'غلاية مياه',
    'wifi': 'واي فاي',
    'wi-fi': 'واي فاي',
    'internet': 'إنترنت',
    'heater': 'سخان',
    'water heater': 'سخان مياه',
    'dishwasher': 'غسالة صحون',
    'blender': 'خلاط',
    'toaster': 'محمصة',
    'coffee maker': 'ماكينة قهوة',
    'hair dryer': 'مجفف شعر',
    'vacuum cleaner': 'مكنسة كهربائية',
    'safe': 'خزنة',
    'safe box': 'خزنة',
    'parking': 'موقف سيارات',
    'pool': 'مسبح',
    'swimming pool': 'مسبح',
    'balcony': 'بلكونة',
    'elevator': 'مصعد',
    'lift': 'مصعد',
    'gym': 'صالة رياضية',
    'bbq': 'شوايه',
    'barbecue': 'شوايه',
    'security': 'أمن وحراسة',
    'camera': 'كاميرات مراقبة',
    'cctv': 'كاميرات مراقبة',
  };

  /// Returns the Arabic label for [serviceName], or [serviceName] itself
  /// if no translation is available.
  static String translate(String serviceName) {
    final key = serviceName.trim().toLowerCase();
    return _arabicNames[key] ?? serviceName;
  }
}