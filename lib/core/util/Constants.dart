import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String DEFAULT_COUNTRY_CODE_NUM = "968";
const String DEFAULT_COUNTRY_CODE = "OM";
const VALUE_LANGUAGE_EN = "en";
const VALUE_LANGUAGE_AR = "ar";
const APP_LAUNCHED = "APP_LAUNCHED";
const CACHED_CHALET = "CACHED_CHALET";
const OTP = "OTP";
const PHONE_NUMBER = "PHONE_NUMBER";
const MAX_LENGTH_TEXT_DEFAULT = 200;
const MAX_LENGTH_TEXT_PHONE = 22;
const MAX_LENGTH_TEXT_Name = 14;
const MAX_LENGTH_TEXT_EMAIL = 70;
const PADDING_PAGE = EdgeInsets.all(20);

const IS_LOGIN = "IS_LOGIN";
const USER_PROFILE = "USER_PROFILE";

const DEFAULT_CORNER = 16.0;

const PAGE_SIZE_CHALETS_PAGINATION = 10;

const PAGE_SIZE_BUILDINGS_PAGINATION = 10;

const SUCCESS_URL = "https://shleeh.com/RequestPay/Success";
const FAIL_URL = "https://www.shleeh.com/RequestPay/Error";
const INIT_PAY_URL = "https://shleeh.com/RequestPay/IPAY?id";
const PRIVACY_URL = "https://shleeh.com/homepage/usertermsar.html";

Map<String, String> statesEnglishToArabic = {
  // "Salalalh": "صلالة",
  "Salalah": "صلالة",

  'Taqah': 'طاقة',
  'Mirbat': 'مرباط',
  'Thumrait': 'ثمريت',
  'Dalkut': 'ضلكوت',
  'Rakhyut': 'رخيوت',
  'Shalim': 'شليم',
  'AL mazyona': 'المزيونة',
  'Sadah': 'صدح',
  'Maushan': 'مقشن',
};

Map<String, String> serviceKeyToValue = {
  // Original Services
  'sec_24': 'حراسة 24/7',
  'Security 24/7': 'حراسة 24/7',
  'wifi': 'واي فاي',
  'parking': 'مواقف',
  'elevator': 'مصعد',
  'ac': 'تكييف الهواء',
  'gym': 'صالة رياضية',
  'pool': 'مسبح',
  'power': 'طاقة كهربائية',
  'cctv': 'كاميرات مراقبة',

  // Additional Services
  'menPool': 'مسبح الرجال',
  'womenPool': 'مسبح النساء',
  'childGames': 'ألعاب أطفال',
  'games': 'ألعاب',
  'grill': 'شواية',
  'animals': 'حيوانات',
  'volleyBall': 'كرة طائرة',
  'childPool': 'مسبح أطفال',
  'football': 'كرة قدم',
  'noSmoking': 'ممنوع التدخين',
};

// Map<String, bool> selectedServices = {
//   // Original Services
//   'sec_24': false,
//   'wifi': false,
//   'parking': false,
//   'elevator': false,
//   'ac': false,
//   'gym': false,
//   'pool': false,
//   'power': false,
//   'cctv': false,
//
//   // Additional Services
//   'menPool': false,
//   'womenPool': false,
//   'childGames': false,
//   'games': false,
//   'grill': false,
//   'animals': false,
//   'volleyBall': false,
//   'childPool': false,
//   'football': false,
//   'noSmoking': false,
// };

List<String> governorates = ["Dhofar"];
Map<String, String> governoratesEnglishToArabic = {
  "Dhofar": "ظفار",
  // "Dhofar" :"ظفار"

};

List<String> states = [
  // "Salalalh",
  "Salalah",
  "Mirbat",
  "Sadah",
  "Shalim",
  "Thumrait",
  "Maqusht",
  "Dalkut",
  "Rakhyut",
  "AL mazyona",
  "Taqah"
];
Map<String, String> statesEnglishToArabicFilter = {
  // "Salalalh": "صلالة",
  "Salalah": "صلالة",
  "Mirbat": "مرباط",
  "Sadah": "سدح",
  "Shalim": "شليم",
  "Thumrait": "ثمريت",
  "Maqusht": "مقشن",
  "Dalkut": "ضلكوت",
  "Rakhyut": "رخيوت",
  "AL mazyona": "المزيونة",
  "Taqah": "طاقة",
};

// This must mirror the real, literal chalet services list from the owner
// web panel's AddChaletModal.jsx (see CHALET_SERVICES in
// shleeh_com_customer/src/core/utils/constants.js, which was built from
// that exact same source) — a chalet listing can only ever actually have
// these 8 services, so offering anything else as a filter chip lets a
// guest "select" a service no listing will ever match. The previous list
// here was wrong on both sides: missing 'wifi'/'noSmoking' (real services
// no one could filter by) and including 'volleyBall'/'childPool'/'football'
// (services that don't exist on the add/edit chalet form at all).
List<String> services = [
  'wifi',
  'menPool',
  'womenPool',
  'childGames',
  'games',
  'noSmoking',
  'grill',
  'animals',
];
Map<String, String> servicesEnglishToArabic = {
  'sec_24': "حراسة 24/7",
  'Security 24/7': 'حراسة 24/7',

  'wifi': "واي فاي",
  'parking': "مواقف",
  'elevator': "مصعد",
  'Air Conditioning': "تكييف الهواء",
  'gym': "صالة رياضية",
  'pool': "مسبح",
  'power': "طاقة كهربائية",
  'cctv': "كاميرات مراقبة",

  // Additional Services
  'menPool': "مسبح رجال",
  'womenPool': "مسبح نساء",
  'grill': "شواية",
  'volleyBall': "كرة طائرة",
  'animals': "حيوانات",
  'childPool': "مسبح أطفال",
  'football': "كرة قدم",
  'games': "ألعاب",
  'childGames': "ألعاب أطفال",
  'Parking': "مواقف",
  // Was missing from this specific map (present in serviceKeyToValue
  // above, but filter_widget.dart reads from this one) — the chalet
  // filter's "noSmoking" chip fell through to `?? service` and showed
  // the raw English key instead of an Arabic label.
  'noSmoking': "ممنوع التدخين",

};

Map<String, String> servicesEnglishToArabicBuilding = {
  'security 24/7': 'أمن على مدار الساعة',
  'wifi': 'واي فاي',
  'parking': 'موقف سيارات',
  'elevator': 'مصعد',
  'air conditioning': 'تكييف هواء',
  'gym': 'صالة رياضية',
  'swimming pool': 'حمام سباحة',
  'power backup': 'مولد كهرباء احتياطي',
  'cctv': 'كاميرات مراقبة',

};
Map<String, IconData> serviceIconsBuilding = {
  'Security 24/7': Icons.security_rounded,
  'WiFi': Icons.wifi_rounded,
  'Parking': Icons.local_parking_rounded,
  'Elevator': Icons.elevator_rounded,
  'Air Conditioning': Icons.ac_unit_rounded,
  'Gym': Icons.fitness_center_rounded,
  'Swimming Pool': Icons.pool_rounded,
  'Power Backup': Icons.flash_on_rounded,
  'CCTV': Icons.videocam_rounded
};
// Built-in Material icons — no asset files needed.

Map<String, IconData> serviceIcons = {
  // Original Services
  'sec_24': Icons.security_rounded,
  'wifi': Icons.wifi_rounded,
  'noSmoking': Icons.smoke_free_rounded,

  // Additional Services
  'menPool': Icons.pool_rounded,
  'womenPool': Icons.pool_outlined,
  'grill': Icons.outdoor_grill_rounded,
  'volleyBall': Icons.sports_volleyball_rounded,
  'animals': Icons.pets_rounded,
  'childPool': Icons.child_friendly_rounded,
  'football': Icons.sports_soccer_rounded,
  'games': Icons.sports_esports_rounded,
  'childGames': Icons.toys_rounded,
};

