import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';

/// "Pay 25% deposit, pay the rest on arrival" checkbox row.
class DepositCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const DepositCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              checkColor: Colors.white,
              activeColor: primaryColor,
              onChanged: (v) => onChanged(v ?? false),
            ),
            Flexible(
              child: Text(
                "دفع عربون (٢٥ ٪) ودفع المبلغ المتبقي عند الوصول",
                style: TextStyles.textStyleBody(context),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}