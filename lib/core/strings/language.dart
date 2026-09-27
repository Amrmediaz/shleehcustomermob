import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

String getTextByKey({ required String key, Map<String, String>? namedArgs}) {
  return tr(key, namedArgs: namedArgs);
}
// Updated TranslationKey class with new gallery and image keys
// lib/core/strings/translation_keys.dart

class TranslationKey {
 // ===== EXISTING KEYS =====

 // Navigation & General
 static const String keyNext = 'keyNext';
 static const String keyGetStarted = 'keyGetStarted';
 static const String keySkip = 'keySkip';
 static const String keyBack = 'keyBack';
 static const String keyClose = 'keyClose';

 static const String keyBuildingsByDates = 'keyBuildingsByDates';



 // Form Validation
 static const String keyFillField = 'keyFillField';
 static const String keyEmptyField = 'keyEmptyField';
 static const String keyEmpty = 'keyEmpty';
 static const String keyEmptyOrShort = 'keyEmptyOrShort';
 static const String keyRequiredFillData = 'keyRequiredFillData';

 // Onboarding
 static const String keyOnBoardFirstDescription = 'keyOnBoardFirstDescription';
 static const String keyOnBoardSecondDescription = 'keyOnBoardSecondDescription';
 static const String keyOnBoardThirdDescription = 'keyOnBoardThirdDescription';
 static const String keyOnBoardFirstTitle = 'keyOnBoardFirstTitle';
 static const String keyOnBoardSecondTitle = 'keyOnBoardSecondTitle';
 static const String keyOnBoardThirdTitle = 'keyOnBoardThirdTitle';

 // Authentication
 static const String keyPassword = 'keyPassword';
 static const String keyUserName = 'keyUserName';
 static const String keyPhoneNumber = 'keyPhoneNumber';
 static const String keyEnterPassword = 'keyEnterPassword';
 static const String keyLogin = 'keyLogin';
 static const String keySkipLogin = 'keySkipLogin';
 static const String keyLoginWithBiometric = 'keyLoginWithBiometric';
 static const String keyBiometricLoginFailed = 'keyBiometricLoginFailed';
 static const String keyBiometricPaymentFailed = 'keyBiometricPaymentFailed';
 static const String keyLoginDes = 'keyLoginDes';
 static const String keyRegisterNewAccount = 'keyRegisterNewAccount';
 static const String keyCreateNewAccount = 'keyCreateNewAccount';
 static const String keyNotRegister = 'keyNotRegister';
 static const String keyUnsuccefullLogin = 'keyUnsuccefullLogin';
 static const String keyLoginSuccessMessage = 'keyLoginSuccessMessage';
 static const String keyEmail = 'keyEmail';
 static const String keyEmailEmpty = 'keyEmailEmpty';
 static const String keyEmailInvalid = 'keyEmailInvalid';

 // Password Management
 static const String keySessionExpired = 'keySessionExpired';
 static const String keyResetPassword = 'keyResetPassword';
 static const String keyResetDes = 'keyResetDes';
 static const String keyResetGuide = 'keyResetGuide';
 static const String keyResetPasswordSuccessMessage = 'keyResetPasswordSuccessMessage';
 static const String keyResetPasswordSuccessSMSSent = 'keyResetPasswordSuccessSMSSent';
 static const String keyResetPasswordFailedMessage = 'keyResetPasswordFailedMessage';
 static const String keyPasswordMatch = 'keyPasswordMatch';
 static const String keyRequiredPassword = 'keyRequiredPassword';
 static const String keyPasswordLength = 'keyPasswordLength';
 static const String keyPasswordUpperCase = 'keyPasswordUpperCase';
 static const String keyPasswordLowerCase = 'keyPasswordLowerCase';
 static const String keyPasswordDigit = 'keyPasswordDigit';
 static const String keyPasswordSpecialCharacter = 'keyPasswordSpecialCharacter';
 static const String keyPasswordNotMatch = 'keyPasswordNotMatch';
 static const String keyPasswordRules = 'keyPasswordRules';

 // OTP
 static const String keySendOtp = 'keySendOtp';
 static const String keyVerifyOtp = 'keyVerifyOtp';
 static const String keyEnterOtp = 'keyEnterOtp';
 static const String keyEnterYourPhone = 'keyEnterYourPhone';
 static const String keyOTP = 'keyOTP';
 static const String keyWrongOtp = 'keyWrongOtp';
 static const String keyShouldOTPMatch = 'keyShouldOTPMatch';
 static const String keyOtpSentSuccessMessage = 'keyOtpSentSuccessMessage';
 static const String keyOtpVerifiedSuccessMessage = 'keyOtpVerifiedSuccessMessage';

 // User Registration
 static const String keyExistUser = 'keyExistUser';
 static const String keyLoginExistUser = 'keyLoginExistUser';
 static const String keyRegisterAccount = 'keyRegisterAccount';
 static const String keyFirstName = 'keyFirstName';
 static const String keyLastName = 'keyLastName';
 static const String keySuccessRegisterTitle = 'keySuccessRegisterTitle';
 static const String keySuccessRegisterMsg = 'keySuccessRegisterMsg';

 // Navigation Menu
 static const String keySubjects = 'keySubjects';
 static const String keyRecommendations = 'keyRecommendations';
 static const String keyCompliments = 'keyCompliments';
 static const String keySettings = 'keySettings';
 static const String keyChalets = 'keyChalets';
 static const String keyFlats = 'keyFlats';



 // Errors
 static const String keyError = 'keyError';
 static const String keyNoInternet = 'keyNoInternet';
 static const String keyServerError = 'keyServerError';
 static const String keyRetry = 'keyRetry';

 // Other
 static const String keyNo = 'keyNo';

 // ===== CHALET LISTING & PRICE =====

 static const String keyStartFrom = 'keyStartFrom';
 static const String keyOMR = 'keyOMR';
 static const String keyPrice = 'keyPrice';
 static const String keyFilter = 'keyFilter';
 static const String keyMap = 'keyMap';
 static const String keyFindIdealChalet = 'keyFindIdealChalet';
 static const String keyFiltersActiveTapToEdit = 'keyFiltersActiveTapToEdit';
 static const String keyExploreOnMap = 'keyExploreOnMap';
 static const String keyHighLowPrice = 'keyHighLowPrice';
 static const String keyLowHighPrice = 'keyLowHighPrice';

 // Details
 static const String keyDescription = 'keyDescription';
 static const String keyPrices = 'keyPrices';
 static const String keyTerms = 'keyTerms';
 static const String keyWeekPrices = 'keyWeekPrices';
 static const String keyWeekendPrices = 'keyWeekendPrices';
 static const String keyBook = 'keyBook';

 // Filters
 static const String keySelectGovernorate = 'keySelectGovernorate';
 static const String keyChooseGovernorate = 'keyChooseGovernorate';
 static const String keySelectState = 'keySelectState';
 static const String keyChooseState = 'keyChooseState';
 static const String keySelectPriceRange = 'keySelectPriceRange';
 static const String keySelectServices = 'keySelectServices';
 static const String keyAvailableServices = 'keyAvailableServices';
 static const String keyApplyFilters = 'keyApplyFilters';
 static const String keyLocation = 'keyLocation';
 static const String keyNoData = 'keyNoData';

 // Booking
 static const String keyChaletsByDates = 'keyChaletsByDates';
 static const String keySelectBookingDate = 'keySelectBookingDate';
 static const String keySelectBookingDateDet = 'keySelectBookingDateDet';

 // Payment
 static const String keyOnlinePayment = 'keyOnlinePayment';
 static const String keyPay = 'keyPay';
 static const String keyTransferPayment = 'keyTransferPayment';
 static const String keySelectPaymentMethod = 'keySelectPaymentMethod';
 static const String keyBankMuscat = 'keyBankMuscat';
 static const String keyBankDohfar = 'keyBankDohfar';
 static const String keyBookingPrice = 'keyBookingPrice';
 static const String keyBookingPriceWithInsurance = 'keyBookingPriceWithInsurance';

 static const String keyDays = 'keyDays';
 static const String keyPriceNote = 'keyPriceNote';
 static const String keyInsurance = 'keyInsurance';
 static const String keyDaysCost = 'keyDaysCost';
 static const String keyDatesBooked = 'keyDatesBooked';
 static const String keyPleaseSelectAnotherDates = 'keyPleaseSelectAnotherDates';

 // Payment-method row descriptions (used by the redesigned PaymentMethodWidget)
 static const String keyOnlinePaymentDesc = 'keyOnlinePaymentDesc';
 static const String keyTransferPaymentDesc = 'keyTransferPaymentDesc';
 static const String keyQpayNotAvailableWithDeposit = 'keyQpayNotAvailableWithDeposit';

 // QPay (installments) — mirrors shleeh_com_customer's dictionary.js QPay keys
 static const String keyQpayLabel = 'keyQpayLabel';
 static const String keyQpayDesc = 'keyQpayDesc';
 static const String keyQpayDueToday = 'keyQpayDueToday';
 static const String keyQpayPhoneTitle = 'keyQpayPhoneTitle';
 static const String keyQpayPhoneSub = 'keyQpayPhoneSub';
 static const String keyQpayPhonePlaceholder = 'keyQpayPhonePlaceholder';
 static const String keyQpayPhoneInvalid = 'keyQpayPhoneInvalid';
 // Persistent helper note under the phone field (not an error) — the
 // number entered here is looked up against QPay's own registry, so it
 // must be the number the user actually registered with QPay, not just
 // any number.
 static const String keyQpayPhoneHelper = 'keyQpayPhoneHelper';
 // Shown on booking details when the booking has an active QPay
 // installment loan (isLoan == true, loanId present) — lets the customer
 // reference that id when following up with QPay directly.
 static const String keyQpayLoanIdLabel = 'keyQpayLoanIdLabel';
 static const String keyQpayLoanIdNote = 'keyQpayLoanIdNote';
 static const String keyQpayContinue = 'keyQpayContinue';
 static const String keyQpayStepPlan = 'keyQpayStepPlan';
 static const String keyQpayStepVerify = 'keyQpayStepVerify';
 static const String keyQpayStepCard = 'keyQpayStepCard';
 static const String keyQpayStepConfirm = 'keyQpayStepConfirm';
 static const String keyQpayChoosePlanTitle = 'keyQpayChoosePlanTitle';
 static const String keyQpayChoosePlanSub = 'keyQpayChoosePlanSub';
 static const String keyQpayPlanInstallments = 'keyQpayPlanInstallments';
 static const String keyQpayPlanFirstDue = 'keyQpayPlanFirstDue';
 static const String keyQpayPlanTotal = 'keyQpayPlanTotal';
 static const String keyQpayMostPopular = 'keyQpayMostPopular';
 static const String keyQpayInstallmentUnit = 'keyQpayInstallmentUnit';
 static const String keyQpayVerifyTitle = 'keyQpayVerifyTitle';
 static const String keyQpayVerifySub = 'keyQpayVerifySub';
 static const String keyQpayCodeSentTo = 'keyQpayCodeSentTo';
 static const String keyQpayResendCode = 'keyQpayResendCode';
 static const String keyQpayVerifyContinue = 'keyQpayVerifyContinue';
 static const String keyQpayPayWithTitle = 'keyQpayPayWithTitle';
 static const String keyQpayPayWithSub = 'keyQpayPayWithSub';
 static const String keyQpayUseThisCard = 'keyQpayUseThisCard';
 static const String keyQpayReviewTitle = 'keyQpayReviewTitle';
 static const String keyQpayReviewSub = 'keyQpayReviewSub';
 static const String keyQpaySummaryPlan = 'keyQpaySummaryPlan';
 static const String keyQpaySummaryMonthly = 'keyQpaySummaryMonthly';
 static const String keyQpaySummaryCard = 'keyQpaySummaryCard';
 static const String keyQpaySummaryTotal = 'keyQpaySummaryTotal';
 static const String keyQpayConfirmPurchase = 'keyQpayConfirmPurchase';
 static const String keyQpaySuccessTitle = 'keyQpaySuccessTitle';
 static const String keyQpaySuccessSub = 'keyQpaySuccessSub';
 static const String keyQpayBackToPaymentChoice = 'keyQpayBackToPaymentChoice';
 static const String keyCheckDateAvailability = 'keyCheckDateAvailability';
 static const String keyCopied = 'keyCopied';
 static const String keyConfirmAccountTransfer = 'keyConfirmAccountTransfer';
 static const String keySuccessPayment = 'keySuccessPayment';
 static const String keySuccessPaymentDescription = 'keySuccessPaymentDescription';
 static const String keyFailPayment = 'keyFailPayment';
 static const String keyFailPaymentDescription = 'keyFailPaymentDescription';

 // User Bookings
 static const String keyShouldLogin = 'keyShouldLogin';
 static const String keyMyBookings = 'keyMyBookings';
 static const String keyBookingNumber = 'keyBookingNumber';
 static const String keyPayConfoirm = 'keyPayConfoirm';
 static const String keyConfirmed = 'keyConfirmed';
 static const String keyBookingDate = 'keyBookingDate';
 static const String keyBookingTime = 'keyBookingTime';
 static const String keyFullDay = 'keyFullDay';
 static const String keyHalfDay = 'keyHalfDay';
 static const String keyDisplayChalet = 'keyDisplayChalet';
 static const String keyDisplayFlat = 'keyDisplayFlat';


 static const String keyBookingDetails = 'keyBookingDetails';

 // Account Management
 static const String keyAccountManagement = 'keyAccountManagement';
 static const String keySupport = 'keySupport';
 static const String keySignOut = 'keySignOut';
 static const String keyContactSupport = 'keyContactSupport';
 static const String keyPrivacy = 'keyPrivacy';
 static const String keyContactWhatsApp = 'keyContactWhatsApp';
 static const String keySaveData = 'keySaveData';
 static const String keyDeleteMyAccount = 'keyDeleteMyAccount';
 static const String keyDeleteAccount = 'keyDeleteAccount';
 static const String keyAreYouSureMakeTodeleteTheAccount = 'keyAreYouSureMakeTodeleteTheAccount';
 static const String deleteTheAccountPermant = 'deleteTheAccountPermant';
 static const String keySuccessUpdateProfile = 'keySuccessUpdateProfile';
 static const String keySuccessDeleteProfile = 'keySuccessDeleteProfile';

 // ===== NEW: IMAGE GALLERY & CHALET DETAILS =====

 // Image Loading & Display
 static const String keyLoadingImage = 'keyLoadingImage';
 static const String keyImageNotAvailable = 'keyImageNotAvailable';
 static const String keyLoading = 'keyLoading';
 static const String keyErrorLoadingImage = 'keyErrorLoadingImage';

 // Price Display
 static const String keyBestPriceStartingFrom = 'keyBestPriceStartingFrom';
 static const String keyPerNight = 'keyPerNight';
 static const String keyTaxesAndFeesNotIncluded = 'keyTaxesAndFeesNotIncluded';

 // Reviews & Rating
 static const String keyReviews = 'keyReviews';
 static const String keyRating = 'keyRating';

 // Booking & Actions
 static const String keyBookYourStay = 'keyBookYourStay';
 static const String keyViewAllImages = 'keyViewAllImages';

 // Gallery
 static const String keyGallery = 'keyGallery';
 static const String keyFullScreen = 'keyFullScreen';
 static const String keyNextImage = 'keyNextImage';
 static const String keyPreviousImage = 'keyPreviousImage';
 static const String keyZoomIn = 'keyZoomIn';
 static const String keyZoomOut = 'keyZoomOut';
 static const String keySwipeToNavigate = 'keySwipeToNavigate';
 static const String keyPinchToZoom = 'keyPinchToZoom';

 // Favorites
 static const String keySaveToFavorites = 'keySaveToFavorites';
 static const String keyRemoveFromFavorites = 'keyRemoveFromFavorites';
 static const String keyFavoritesLimitReached = 'keyFavoritesLimitReached';

 // Property Details
 static const String keyCapacity = 'keyCapacity';
 static const String keyBedrooms = 'keyBedrooms';
 static const String keyBathrooms = 'keyBathrooms';
 static const String keyAmenities = 'keyAmenities';
 static const String keyOf = 'keyOf';



 // Contact & Share
 static const String keyReportListing = 'keyReportListing';
 static const String keyCallOwner = 'keyCallOwner';
 static const String keyMessageOwner = 'keyMessageOwner';
 static const String keyShareListing = 'keyShareListing';

 // Services (Amenities)
 static const String keyWiFi = 'keyWiFi';
 static const String keyParking = 'keyParking';
 static const String keySwimmingPool = 'keySwimmingPool';
 static const String keyGym = 'keyGym';
 static const String keyAirConditioning = 'keyAirConditioning';
 static const String keyKitchen = 'keyKitchen';
 static const String keyBalcony = 'keyBalcony';
 static const String keyGarden = 'keyGarden';
 static const String keySecurity = 'keySecurity';
 static const String keyCleaningService = 'keyCleaningService';
 static const String keyBreakfast = 'keyBreakfast';
 static const String keyLunch = 'keyLunch';
 static const String keyDinner = 'keyDinner';
 static const String keyTV = 'keyTV';
 static const String keyNoSmoking = 'keyNoSmoking';


 static const String keybuildingsByDates = 'keybuildingsByDates';
 static const String keyFloors = 'keyFloors';
 static const String keyUnits = 'keyUnits';
 static const String keyYear = 'keyYear';
 static const String keyCheckIn = 'keyCheckIn';
 static const String keyCheckOut = 'keyCheckOut';

 // Price Keys
 static const String keyPriceRangePerNight = 'keyPriceRangePerNight';
 static const String keyMinimum = 'keyMinimum';
 static const String keyMaximum = 'keyMaximum';

 // Tab & Section Keys
 static const String keyFlatTypes = 'keyFlatTypes';
 static const String keyPolicies = 'keyPolicies';


 // Description Keys
 static const String keyNoDescriptionAvailable = 'keyNoDescriptionAvailable';
 static const String keyNoServicesAvailable = 'keyNoServicesAvailable';

 // Flat Type Keys
 static const String keyAvailableFlatTypes = 'keyAvailableFlatTypes';
 static const String keyStudio = 'keyStudio';
 static const String keyOneBedroom = 'keyOneBedroom';
 static const String keyTwoBedroom = 'keyTwoBedroom';
 static const String keyThreeBedroom = 'keyThreeBedroom';
 static const String keyBedroom = 'keyBedroom';
 static const String keyBathroom = 'keyBathroom';
 static const String keySquareMeter = 'keySquareMeter';

 // Policy Keys
 static const String keyBuildingPolicy = 'keyBuildingPolicy';
 static const String keyCancellationPolicy = 'keyCancellationPolicy';
 static const String keyContactInformation = 'keyContactInformation';
 static const String keyManagement = 'keyManagement';
 static const String keyWorker = 'keyWorker';
 static const String keyNotSpecified = 'keyNotSpecified';


 static const String keyNA = 'keyNA';

 // Rating Keys (for future use)
 static const String keyStar = 'keyStar';
 static const String keyStars = 'keyStars';
 static const String keyChaletType = 'keyChaletType';
 static const String keySelectChaletType = 'keySelectChaletType';
 static const String keyName = 'keyName';
 static const String keySearchByName = 'keySearchByName';
 static const String keyRate = 'keyRate';
 static const String keyLivingRooms = 'keyLivingRooms';
 static const String keyLandscape = 'keyLandscape';
 static const String keyBestSeason = 'keyBestSeason';
 static const String keyArea = 'keyArea';
 static const String keySelectDates = 'keySelectDates';
 static const String keyConfirm = 'keyConfirm';

 static const String keyMoreFilters = 'keyMoreFilters';

}