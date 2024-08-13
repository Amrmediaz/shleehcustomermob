import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:flutter/material.dart';

class ActionBtn extends StatelessWidget {
  final void Function() onPressed;
  final String btnTitle;
  final Color btnColor;
  final Color? btnTxtColor;
  final Color? borderColor;
  final bool? isLoading;
  const ActionBtn(
      {Key? key,
      this.btnTxtColor,
      this.borderColor,
      this.isLoading,
      required this.onPressed,
      required this.btnTitle,
      required this.btnColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                    color: borderColor ?? btnColor,
                    width: 0.7) // Adjust the radius as needed
                ),
          ),
          onPressed: onPressed,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Visibility(
                visible: isLoading == null
                    ? true
                    : isLoading == true
                        ? false
                        : true,
                child: Text(
                  getTextByKey(key: btnTitle),
                  textAlign: TextAlign.center,
                  style: TextStyles.textStyleButton(context)
                      .copyWith(color: btnTxtColor ?? Colors.white),
                )),
            Visibility(
                visible: isLoading ?? false,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ))
          ])),
    );
  }
}
