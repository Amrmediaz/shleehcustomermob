/// Translates the raw English enum keys the "chalet characteristics"
/// fields (landscape, suitableFor, outdoorSpace, safety, atmosphere,
/// bestSeason) are actually stored as on the backend — e.g. `coastal`,
/// `small_family`, `large_garden` — into their Arabic labels for display
/// on the customer app.
///
/// These fields are populated from a fixed multiple-choice list on the
/// owner side (see chaletowner/lib/chalet_screen/add_chalet.dart's
/// `landscapeArabicToEnglish` / `suitableForArabicToEnglish` / etc. maps,
/// mirrored on the web owner panel's ChaletCharacteristicsSection.jsx),
/// but the customer app was rendering the raw stored value straight
/// through with no reverse-mapping at all — so instead of "ساحلي" a
/// chalet would show the literal word "coastal" (or "Costal" for
/// records saved with an old/mistyped value) on both the list card and
/// the detail page. This file is the single reverse-mapping used by
/// both places, so a fix here covers the whole app instead of two
/// separately-drifting copies.
library characteristics_translator;

/// Full-length Arabic label (e.g. "ساحلي (قرب البحر)") — one merged map
/// since the keys don't collide across the six fields.
const Map<String, String> _fullLabels = {
  // landscape
  'coastal': 'ساحلي (قرب البحر)',
  'mountain': 'جبلي (جبال وطبيعة)',
  'valley': 'وادي (خضرة وهدوء)',
  'desert': 'صحراوي (رمال هادئة)',
  // suitableFor
  'small_family': 'عائلات صغيرة (2-4 أفراد)',
  'large_family': 'عائلات كبيرة (5+ أفراد)',
  'couples': 'أزواج',
  'friends_group': 'مجموعات أصدقاء',
  'corporate': 'موظفين شركات',
  // outdoorSpace
  'large_garden': 'حديقة واسعة جداً',
  'medium_garden': 'حديقة متوسطة',
  'small_yard': 'فناء صغير',
  'balcony_only': 'شرفة فقط',
  // safety
  'very_safe_children': 'آمنة جداً للأطفال',
  'generally_safe': 'آمنة عموماً',
  'adults_only': 'مناسبة للبالغين فقط',
  // atmosphere
  'very_calm': 'هادئة جداً (للاسترخاء)',
  'calm_comfortable': 'هادئة ومريحة',
  'lively': 'نشيطة وحيوية',
  // bestSeason
  'summer': 'الصيف (حار)',
  'winter': 'الشتاء (بارد - الأفضل)',
  'spring_autumn': 'الربيع والخريف',
  'year_round': 'طول السنة',
};

/// Known misspellings / alternate spellings seen in real stored data
/// (e.g. "Costal" missing the second "a"), normalized to the correct
/// key before lookup.
const Map<String, String> _aliases = {
  'costal': 'coastal',
  'moutain': 'mountain',
  'mountains': 'mountain',
  'valey': 'valley',
  'deserts': 'desert',
  'smallfamily': 'small_family',
  'largefamily': 'large_family',
  'friendsgroup': 'friends_group',
  'largegarden': 'large_garden',
  'mediumgarden': 'medium_garden',
  'smallyard': 'small_yard',
  'balconyonly': 'balcony_only',
  'verysafechildren': 'very_safe_children',
  'generallysafe': 'generally_safe',
  'adultsonly': 'adults_only',
  'verycalm': 'very_calm',
  'calmcomfortable': 'calm_comfortable',
  'springautumn': 'spring_autumn',
  'yearround': 'year_round',
};

final RegExp _arabicChar = RegExp(r'[؀-ۿ]');

String _normalizeKey(String raw) {
  var key = raw.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
  // collapse "very__safe" style doubles from the space/hyphen swap above
  key = key.replaceAll(RegExp(r'_+'), '_');
  return _aliases[key.replaceAll('_', '')] ?? _aliases[key] ?? key;
}

/// Translates a single characteristic token. Already-Arabic values (older
/// free-text records, or anything saved before the fixed-choice lists
/// existed) are returned unchanged — only bare English/unknown tokens get
/// looked up. Falls back to the original text if there's truly no match,
/// rather than hiding data the owner did provide.
String translateCharacteristicToken(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;
  if (_arabicChar.hasMatch(trimmed)) return trimmed;

  final key = _normalizeKey(trimmed);
  return _fullLabels[key] ?? trimmed;
}

/// Same as [translateCharacteristicToken] but strips the parenthetical
/// detail ("ساحلي (قرب البحر)" -> "ساحلي") — used for compact spots like
/// list-card chips where there isn't room for the full descriptive label.
String translateCharacteristicTokenShort(String raw) {
  final full = translateCharacteristicToken(raw);
  return full.split('(').first.trim();
}

/// Handles comma-separated multi-select fields (landscape, suitableFor
/// can carry more than one value) — translates every token and rejoins
/// with an Arabic-style separator.
String translateCharacteristicList(String raw) {
  if (raw.trim().isEmpty) return raw;
  final parts = raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
  return parts.map(translateCharacteristicToken).join('، ');
}
