import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/pages/login_page.dart';
import 'package:shleehcustomer/features/landing/presentation/widgets/on_board_widget.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
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

class _OnBoardPageWidgetState extends State<OnBoardPageWidget>
    with SingleTickerProviderStateMixin {
  late PageController pageController;
  late AnimationController _animationController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (currentIndex < widget.onboards.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLoginPage();
    }
  }

  void _navigateToLoginPage() {
    CasheFile().setAppLaunched();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _skipOnboarding() {
    CasheFile().setAppLaunched();
    _navigateToLoginPage();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentIndex == widget.onboards.length - 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Column(
          children: [
            // ── Skip Button (Top Right)
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      getTextByKey(key: TranslationKey.keySkip),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── PageView
            Expanded(
              child: PageView.builder(
                controller: pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemCount: widget.onboards.length,
                itemBuilder: (context, index) {
                  return OnboardItemWidget(
                    onboardItem: widget.onboards[index],
                  );
                },
              ),
            ),

            // ── Indicators & Progress
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  // Dots Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.onboards.length,
                          (index) => _buildDot(index),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value:
                        (currentIndex + 1) / widget.onboards.length,
                        minHeight: 4,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          primaryColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Page Counter
                  Text(
                    '${currentIndex + 1} / ${widget.onboards.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // ── Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  // Back Button (Only on screens after first)
                  if (currentIndex > 0)
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOutCubic,
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  size: 18,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'السابق',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (currentIndex > 0) const SizedBox(width: 12),

                  // Next / Get Started Button
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            primaryColor.withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _goToNextPage,
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastPage
                                    ? getTextByKey(
                                    key: TranslationKey.keyGetStarted)
                                    : getTextByKey(key: TranslationKey.keyNext),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dot Indicator Widget
  Widget _buildDot(int index) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: isActive ? 28 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
      ),
    );
  }
}