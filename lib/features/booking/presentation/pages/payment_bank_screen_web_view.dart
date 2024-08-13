import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/util/Constants.dart';
import '../../../../core/util/common_functions.dart';
import '../../../../core/widgets/app_bar_back.dart';
import '../../../chalets/presentation/bloc/chalets/chalets_bloc.dart';
import '../../../home_page/presentation/pages/home_page.dart';
import '../bloc/bookings/bookings_bloc.dart';
import '../widgets/payment/payment_bank_web_widget.dart';

class PaymentBankWebViewScreen extends StatelessWidget {
  final String paymentId;

  const PaymentBankWebViewScreen(
      {super.key, required this.paymentId,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _buildBody(context)));
  }

  Widget _buildBody(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: PADDING_PAGE, children: [
          AppBarBack(leadingWidgetAction: () {
            Navigator.pop(context);
          }),
          PaymentBankWebViewWidget(
            paymentId: paymentId,
          )
        ]));
  }

  moveToBookings(BuildContext context) {
    CommonFunctions.pageNumberBookings = 1;
    BlocProvider.of<BookingsBloc>(context)
        .add(GetAllBookingsEvent(pageNumber: 1, pageSize: 10));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }
}
