import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';

const List<String> dayTypeLabels = ["يوم كامل", "نصف يوم"];

/// Full-day / half-day toggle switch.
class DayTypeToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DayTypeToggle({
    Key? key,
    required this.selectedIndex,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: FlutterToggleTab(
        width: 90,
        borderRadius: 30,
        height: 50,
        selectedIndex: selectedIndex,
        selectedBackgroundColors: [primaryColor, primaryColor],
        selectedTextStyle: TextStyles.textStyleButton(context),
        unSelectedTextStyle: TextStyles.textStyleHelper(context).copyWith(color: Colors.black),
        dataTabs: [
          DataTab(title: dayTypeLabels[0], isSelected: selectedIndex == 0),
          DataTab(title: dayTypeLabels[1], isSelected: selectedIndex == 1),
        ],
        selectedLabelIndex: onChanged,
        isScroll: false,
      ),
    );
  }
}