import '../../strings/language.dart';

class ValidationText {
  static String validatePassword(String value) {
    if (value == null || value.isEmpty) {
      return getTextByKey(key: TranslationKey.keyRequiredPassword);
    }

    if (value.length < 6) {
      return getTextByKey(key: TranslationKey.keyPasswordLength);
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return getTextByKey(key: TranslationKey.keyPasswordUpperCase);
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return getTextByKey(key: TranslationKey.keyPasswordLowerCase);
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return getTextByKey(key: TranslationKey.keyPasswordDigit);
    }

    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return getTextByKey(key: TranslationKey.keyPasswordSpecialCharacter);
    }

    return "";
  }
  static String validateEmail(String email) {
    // Check if the email is empty
    if (email.isEmpty) {
      return getTextByKey(key: TranslationKey.keyEmailEmpty);
    }

    // Use a regular expression to check the email format
    RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return getTextByKey(key: TranslationKey.keyEmailInvalid);

    }

    // If the email is valid
    return '';
  }
}