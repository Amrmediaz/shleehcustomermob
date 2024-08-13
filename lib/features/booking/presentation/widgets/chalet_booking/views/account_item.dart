import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';

import '../../../../../../core/strings/assets_path.dart';
import '../../../../../../core/styles/text/text_style.dart';
import '../../../../../../core/util/Constants.dart';

class AccountItem extends StatelessWidget {
  final String accountNumber;
  final String bankName;
  final String bankIcon;
  AccountItem({required this.accountNumber,required this.bankIcon,required this.bankName});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(DEFAULT_CORNER)),
            border: Border.all(color: Colors.grey.shade400, width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Row(children: [
              Image.asset(bankIcon,width: MediaQuery.of(context).size.width / 12,height: MediaQuery.of(context).size.width / 12,),
              const SizedBox(width: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankName,
                    style: TextStyles.textStyleBody(context)
                        .copyWith(color: Colors.grey.shade500),
                  ),
                  Text(
                    accountNumber,
                    style: TextStyles.textStyleBody(context)
                        .copyWith(color: Colors.grey.shade500),
                  ),

                  Text(
                    "A REHAMAN ABDUL",
                    style: TextStyles.textStyleTitle(context)
                        .copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ) ,
            ],) ,
           InkWell(onTap: (){
             FlutterClipboard.copy(accountNumber);
             Navigator.pop(context);
             ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: primaryColor,
               content: Text(getTextByKey(key: TranslationKey.keyCopied),style: TextStyles.textStyleTitle(context).copyWith(color: Colors.white),),
             ));

           },child: const Icon(Icons.copy , color: Colors.orange,) ,)

          ],
        ));
    ;
  }
}
