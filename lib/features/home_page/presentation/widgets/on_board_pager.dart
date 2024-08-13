import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/pages/login_page.dart';

import 'package:shleehcustomer/features/landing/presentation/widgets/on_board_widget.dart';
import 'package:flutter/material.dart';
import '../../../../core/util/cashed_data/cashed_file.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import '../../../landing/domain/entities/onboard.dart';

class OnBoardPageWidget extends StatefulWidget {
  final List<Onboard> onboards;

  const OnBoardPageWidget({
    Key? key,
    required this.onboards,
  }) : super(key: key);

  @override
  State<OnBoardPageWidget> createState() => _OnBoardPageWidgetState();
}

class _OnBoardPageWidgetState extends State<OnBoardPageWidget> {
  late PageController pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              return PageView.builder(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.onboards.length,
                pageSnapping: true,
                itemBuilder: (context, index) {
                  return OnboardItemWidget(
                    onboardItem: widget.onboards[index], // Use index instead of currentIndex
                  );
                },
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                CasheFile().setAppLaunched();
                navigateToLoginPage();

              },
              child: Text(
                getTextByKey(key: TranslationKey.keySkip),
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (currentIndex < widget.onboards.length - 1) {
                  setState(() {
                    currentIndex++;
                    pageController.animateToPage(
                      currentIndex,
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.ease,
                    );
                  });
                } else {
                  CasheFile().setAppLaunched();
                  navigateToLoginPage();
                }

              },
              child: Text(
                currentIndex == widget.onboards.length - 1
                    ? getTextByKey(key: TranslationKey.keyGetStarted)
                    : getTextByKey(key: TranslationKey.keyNext),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 50,
        )
      ],
    );
  }
  void navigateToLoginPage(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
