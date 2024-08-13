import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/pages/login_page.dart';
import 'package:shleehcustomer/features/booking/presentation/pages/sucess_booking_screen.dart';
import 'package:shleehcustomer/features/home_page/presentation/pages/home_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../core/util/Constants.dart';

class PaymentBankWebViewWidget extends StatefulWidget {
  final String paymentId;
  const PaymentBankWebViewWidget({super.key, required this.paymentId});

  @override
  State<PaymentBankWebViewWidget> createState() =>
      _PaymentBankWebViewWidgetState();
}

WebViewController controller = WebViewController();

class _PaymentBankWebViewWidgetState extends State<PaymentBankWebViewWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initUrl(context);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          )
        :
         Container(height: MediaQuery.of(context).size.height,child: WebViewWidget(controller: controller)

    );
  }

  var isLoading = true;
  void initUrl(BuildContext context) {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            if (progress == 100) {
              isLoading = false;
            } else {
              isLoading = true;
            }
            setState(() {});
          },
          onPageStarted: (String url) {
            print(url);
            if (url == SUCCESS_URL) {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const SuccessBookingScreen(),
                withNavBar: false, // Whether you want to show the bottom nav bar
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            } else if (url == FAIL_URL) {
              CommonFunctions.showBottomDialog(
                  context,
                  const Icon(Icons.error_outline_sharp),
                  getTextByKey(key: TranslationKey.keyFailPayment),
                  getTextByKey(key: TranslationKey.keyFailPayment));
            }
          },
          onPageFinished: (String url) {
            if (url == SUCCESS_URL) {}
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://youtube.com')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('$INIT_PAY_URL=${widget.paymentId}'));
  }
}
