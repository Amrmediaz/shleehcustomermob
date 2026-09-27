import 'package:flutter/services.dart';

enum PaymentMethod {
  transferBanking ,
  onlineBanking ,
  qpay
}


enum TextFormat {
  phoneFormat,
}

extension TextFunctionsExtension on TextFormat {
  FilteringTextInputFormatter get formatter {
    switch (this) {
      case TextFormat.phoneFormat:
        return FilteringTextInputFormatter(
          RegExp(r'[0-9١-٩]'),
          allow: true,
        );
      default:
        return FilteringTextInputFormatter.deny('');
    }
  }
}