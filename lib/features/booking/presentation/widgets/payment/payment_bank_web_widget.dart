import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/pages/login_page.dart';
import 'package:shleehcustomer/features/booking/presentation/pages/sucess_booking_screen.dart';
import 'package:shleehcustomer/features/home_page/presentation/pages/home_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../core/util/Constants.dart';

class PaymentBankWebViewWidget extends StatefulWidget {
  final String paymentUrl;
  const PaymentBankWebViewWidget({super.key, required this.paymentUrl});

  @override
  State<PaymentBankWebViewWidget> createState() =>
      _PaymentBankWebViewWidgetState();
}

class _PaymentBankWebViewWidgetState extends State<PaymentBankWebViewWidget> {
  late final WebViewController _controller;
  double _progress = 0;
  bool _hasResolved = false; // prevents double-navigation on repeated redirects
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
  }

  // Debug-only logging - never prints in a release build, so payment URLs
  // (which can carry tokens) don't end up in production logs.
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[PaymentBankWebView] $message');
    }
  }

  WebViewController _buildController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (!mounted) return;
            setState(() => _progress = progress / 100);
          },
          onPageStarted: (String url) {
            _log('onPageStarted: $url');
            _handleRedirect(url);
          },
          onWebResourceError: (WebResourceError error) {
            _log(
              'onWebResourceError url=${error.url} isForMainFrame=${error.isForMainFrame} '
                  'errorType=${error.errorType} description=${error.description}',
            );
            if (!mounted) return;
            // Payment pages commonly embed third-party scripts, fonts, or
            // analytics that can fail to load for unrelated reasons (ad
            // blockers, flaky network, CORS) without the actual payment
            // page being broken. Only treat this as fatal when we can
            // positively confirm it's the main frame that failed - if the
            // platform can't tell us (isForMainFrame == null, e.g. some
            // iOS cases), we don't blank out the whole screen for a
            // sub-resource hiccup.
            if (error.isForMainFrame == false) return;
            setState(() => _errorMessage = getTextByKey(key: TranslationKey.keyError));
          },
          onNavigationRequest: (NavigationRequest request) {
            _log('onNavigationRequest: ${request.url}');
            if (request.url.startsWith('https://youtube.com')) {
              return NavigationDecision.prevent;
            }
            // The gateway sometimes redirects straight to SUCCESS_URL /
            // FAIL_URL (a plain URL, not the PaymentResult?... page)
            // without that ever showing up in onPageStarted separately -
            // onNavigationRequest fires first and more reliably catches
            // it, so check here too and stop the webview from actually
            // loading that page once we've already handled it.
            if (request.url.startsWith(SUCCESS_URL) || request.url.startsWith(FAIL_URL)) {
              _handleRedirect(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleRedirect(String url) {
    if (_hasResolved || !mounted) return;

    if (url.startsWith(SUCCESS_URL)) {
      _hasResolved = true;
      _log('resolved: success -> $url');
      // Close the payment screen itself before showing success, so "back"
      // from the success screen goes straight to the booking list instead
      // of landing on a finished, blank payment page.
      //
      // NOTE: if you ever see a "Looking up a deactivated widget's
      // ancestor is unsafe" error here, capture `Navigator.of(context)`
      // into a local variable *before* calling pop(), and use that
      // captured reference for the push instead of `context` directly.
      Navigator.of(context).pop();
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const SuccessBookingScreen(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else if (url.startsWith(FAIL_URL)) {
      _hasResolved = true;
      _log('resolved: fail -> $url');
      Navigator.of(context).pop(); // back to booking detail to retry
      CommonFunctions.showBottomDialog(
        context,
        icon: const Icon(Icons.error_outline_sharp),
        title: getTextByKey(key: TranslationKey.keyFailPayment),
        // Was previously the same key as the title (so the dialog showed
        // the same sentence twice). Give the user an actual next step.
        description: 'حدث خطأ أثناء عملية الدفع، برجاء المحاولة مرة أخرى',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_progress < 1)
          LinearProgressIndicator(value: _progress == 0 ? null : _progress),
      ],
    );
  }
}