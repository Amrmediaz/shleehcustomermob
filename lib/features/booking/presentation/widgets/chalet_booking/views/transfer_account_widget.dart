import 'package:flutter/cupertino.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/strings/language.dart';

import 'account_item.dart';

class TransferAccountWidget extends StatelessWidget {
  const TransferAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AccountItem(
          accountNumber: '0397004238490018',
          bankIcon: AssetsPath.bankMuscat,
          bankName: getTextByKey(key: TranslationKey.keyBankMuscat),
        ),
        SizedBox(
          height: 20,
        ),
        AccountItem(
          accountNumber: '01012582574001',
          bankIcon: AssetsPath.bankDohfar,
          bankName: getTextByKey(key: TranslationKey.keyBankDohfar),
        )
      ],
    );
  }
}
