import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

String getTextByKey({ required String key}) {
  return tr(key);
}
class TranslationKey {
  //LandingPage
   //Onboard
    static const String keyNext= "keyNext";
    static const String keyGetStarted= "keyGetStarted";
    static const String keySkip= "keySkip";
    static const String keyFillField= "keyFillField";
    static const String keyEmptyField= "keyEmptyField";
    static const String keyOnBoardFirstDescription= "keyOnBoardFirstDescription";
    static const String keyOnBoardSecondDescription= "keyOnBoardSecondDescription";
    static const String keyOnBoardThirdDescription= "keyOnBoardThirdDescription";
    static const String keyOnBoardFirstTitle= "keyOnBoardFirstTitle";
    static const String keyOnBoardSecondTitle= "keyOnBoardSecondTitle";
    static const String keyOnBoardThirdTitle= "keyOnBoardThirdTitle";


    //Authentication
   //LOGIN
   static const String keyPassword = "keyPassword";
   static const String keyUsername = "keyUserName";
   static const String keyPhoneNumber = "keyPhoneNumber";
   static const String keyEnterPassword = "keyEnterPassword";
   static const String keyLogin = "keyLogin";
   static const String keySkipLogin = "keySkipLogin";
    static const String keyLoginDes = "keyLoginDes";
   static const String keyRegisterNewAccount = "keyRegisterNewAccount";
    static const String keyCreateNewAccount = "keyCreateNewAccount";
    static const String keyNotRegister = "keyNotRegister";
    static const String keyEmpty = "keyEmpty";
    static const String keyEmptyOrShort = "keyEmptyOrShort";
    static const String keyUnsuccefullLogin = "keyUnsuccefullLogin";
    static const String keyLoginSuccessMessage = "keyLoginSuccessMessage";
    static const String keyEmailEmpty = "keyEmailEmpty";
   static const String keyEmailInvalid = "keyEmailInvalid";
    static const String keySessionExpired = "keySessionExpired";



    //RESET PASSWORD
   static const String keyResetPassword = "keyResetPassword";
   static const String keyResetDes = "keyResetDes";
   static const String keyResetGuide = "keyResetGuide";
    static const String keyResetPasswordSuccessMessage = "keyResetPasswordSuccessMessage";
    static const String keyResetPasswordSuccessSMSSent = "keyResetPasswordSuccessSMSSent";

    static const String keyResetPasswordFailedMessage = "keyResetPasswordFailedMessage";



    //OTP
    static const String keySendOtp = "keySendOtp";
    static const String keyVerifyOtp = "keyVerifyOtp";
    static const String keyEnterOtp = "keyEnterOtp";
    static const String keyEnterYourPhone = "keyEnterYourPhone";
    static const String keyExistUser = "keyExistUser";
    static const String keyLoginExistUser = "keyLoginExistUser";
    static const String keyWrongOtp = "keyWrongOtp";
    static const String keyShouldOTPMatch = "keyShouldOTPMatch";
    static const String keyOTP = "keyOTP";




  //REGISTER
    static const String keyEmail = "keyEmail";
    static const String keyPasswordMatch = "keyPasswordMatch";
    static const String keyRegisterAccount = "keyRegisterAccount";
    static const String keyRequiredPassword = "keyRequiredPassword";
    static const String keyPasswordLength = "keyPasswordLength";
    static const String keyPasswordUpperCase = "keyPasswordUpperCase";
    static const String keyPasswordLowerCase = "keyPasswordLowerCase";
    static const String keyPasswordDigit = "keyPasswordDigit";
    static const String keyPasswordSpecialCharacter = "keyPasswordSpecialCharacter";
    static const String keyPasswordNotMatch = "keyPasswordNotMatch";
    static const String keyPasswordRules = "keyPasswordRules";
    static const String keyRequiredFillData = "keyRequiredFillData";
    static const String keyFirstName = "keyFirstName";
    static const String keyLastName = "keyLastName";
    static const String keySuccessRegisterTitle = "keySuccessRegisterTitle";
    static const String keySuccessRegisterMsg = "keySuccessRegisterMsg";





    //HOME PAGE
    static const String keySubjects = "keySubjects";
    static const String keyRecommendations = "keyRecommendations";
    static const String keyCompliments = "keyCompliments";
    static const String keySettings = "keySettings";
    static const String keyChalets = "keyChalets";



    //Common
    static const String keyBack = "keyBack";
    static const String keyOtpSentSuccessMessage = "keyOtpSentSuccessMessage";
    static const String keyOtpVerifiedSuccessMessage = "keyOtpVerifiedSuccessMessage";
    static const String keyError = "keyError";
    static const String keyNoInternet = "keyNoInternet";
    static const String keyNo = "keyNo";


    //chalets
    static const String keyStartFrom = "keyStartFrom";
    static const String keyOMR = "keyOMR";
    static const String keyPrice = "keyPrice";
    static const String keyFilter = "keyFilter";
    static const String keyMap = "keyMap";
    static const String keyHighLowPrice = "keyHighLowPrice";
    static const String keyLowHighPrice = "keyLowHighPrice";
    static const String keyDescription = "keyDescription";
    static const String keyPrices = "keyPrices";
    static const String keyTerms = "keyTerms";
    static const String keyWeekPrices = "keyWeekPrices";
    static const String keyWeekendPrices = "keyWeekendPrices";
    static const String keyBook = "keyBook";
    static const String keySelectGovernorate = "keySelectGovernorate";
    static const String keyChooseGovernorate = "keyChooseGovernorate";
    static const String keySelectState = "keySelectState";
    static const String keyChooseState = "keyChooseState";
    static const String keySelectPriceRange = "keySelectPriceRange";
    static const String keySelectServices = "keySelectServices";
    static const String keyAvailableServices = "keyAvailableServices";

    static const String keyApplyFilters = "keyApplyFilters";
    static const String keyLocation = "keyLocation";
    static const String keyNoData = "keyNoData";
    static const String keyChaletsByDates = "keyChaletsByDates";





    //booking
    static const String keySelectBookingDate = "keySelectBookingDate";
    static const String keySelectBookingDateDet = "keySelectBookingDateDet";
    static const String keyOnlinePayment = "keyOnlinePayment";
    static const String keyPay = "keyPay";

    static const String keyTransferPayment = "keyTransferPayment";
    static const String keySelectPaymentMethod = "keySelectPaymentMethod";
    static const String keyBankMuscat = "keyBankMuscat";
    static const String keyBankDohfar = "keyBankDohfar";
    static const String keyBookingPrice = "keyBookingPrice";
    static const String keyBookingPriceAfterDeposit = "keyBookingPriceAfterDeposit";


    static const String keyDays = "keyDays";
    static const String keyPriceNote = "keyPriceNote";
    static const String keyInsurance = "keyInsurance";
    static const String keyDaysCost = "keyDaysCost";
    static const String keyDatesBooked = "keyDatesBooked";
    static const String keyPleaseSelectAnotherDates = "keyPleaseSelectAnotherDates";
    static const String keyCheckDateAvailability = "keyCheckDateAvailability";
    static const String keyCopied = "keyCopied";
    static const String keyConfirmAccountTransfer = "keyConfirmAccountTransfer";
    static const String keySuccessPayment = "keySuccessPayment";
    static const String keySuccessPaymentDescription = "keySuccessPaymentDescription";
    static const String keyFailPayment = "keyFailPayment";
    static const String keyFailPaymentDescription = "keyFailPaymentDescription";
    static const String keyShouldLogin = "keyShouldLogin";
    static const String keyMyBookings = "keyMyBookings";
    static const String keyBookingNumber = "keyBookingNumber";
    static const String keyPayConfoirm = "keyPayConfoirm";
    static const String keyConfirmed = "keyConfirmed";
    static const String keyBookingDate = "keyBookingDate";
    static const String keyBookingTime = "keyBookingTime";
    static const String keyFullDay = "keyFullDay";
    static const String keyHalfDay = "keyHalfDay";
    static const String keyDisplayChalet = "keyDisplayChalet";
    static const String keyBookingDetails = "keyBookingDetails";





   // settings

    static const String keyAccountManagement = "keyAccountManagement";
    static const String keySupport = "keySupport";
    static const String keySignOut = "keySignOut";
    static const String keyContactSupport = "keyContactSupport";
    static const String  keyPrivacy = "keyPrivacy";
    static const String  keyContactWhatsApp = "keyContactWhatsApp";
    static const String  keySaveData = "keySaveData";
    static const String keyDeleteMyAccount = "keyDeleteMyAccount";
    static const String keyDeleteAccount = "keyDeleteAccount";
    static const String keyAreYouSureMakeTodeleteTheAccount = "keyAreYouSureMakeTodeleteTheAccount";
    static const String deleteTheAccountPermant = "deleteTheAccountPermant";
    static const String keySuccessUpdateProfile = "keySuccessUpdateProfile";
    static const String keySuccessDeleteProfile = "keySuccessDeleteProfile";










}