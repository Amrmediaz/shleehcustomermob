import 'package:flutter/material.dart';

import '../../../../../../core/strings/language.dart';

class ModernTabSelectorWidget extends StatelessWidget {
  final String isClicked;
  final Function(String) onTabSelected;
  final Color primaryColor;

  const ModernTabSelectorWidget({
    Key? key,
    required this.isClicked,
    required this.onTabSelected,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('flats',   getTextByKey(key: TranslationKey.keyAvailableFlatTypes), Icons.apartment_outlined),
      ('description', getTextByKey(key: TranslationKey.keyDescription), Icons.description_outlined),
      ('policies', getTextByKey(key: TranslationKey.keyPolicies), Icons.gavel_outlined),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: tabs.map((tab) {
          final active = isClicked == tab.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(tab.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: active
                      ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.$3,
                      size: 17,
                      color: active ? primaryColor : Colors.grey[400],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tab.$2,
                      style: TextStyle(
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? primaryColor : Colors.grey[500],
                        fontSize: 10,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}