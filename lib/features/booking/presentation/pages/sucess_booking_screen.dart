import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/home_page/presentation/pages/home_page.dart';

import '../../../../core/styles/text/text_style.dart';
import '../../../../core/util/Constants.dart';
import '../../../../core/widgets/app_bar_back.dart';
import '../../../chalets/presentation/bloc/chalets/chalets_bloc.dart';
import '../bloc/bookings/bookings_bloc.dart';
import '../widgets/payment/payment_bank_web_widget.dart';

class SuccessBookingScreen extends StatelessWidget {
  const SuccessBookingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _buildBody(context)));
  }

  Widget _buildBody(BuildContext context) {
    return ListView(padding: PADDING_PAGE, children: [
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.check_circle,
              color: primaryColor,
              size: MediaQuery.of(context).size.width / 3,
            ),
            const SizedBox(height: 16.0),
            Text(
              getTextByKey(key: TranslationKey.keySuccessPayment),
              style: TextStyles.textStyleTitle(context),
            ),
            const SizedBox(height: 12.0),
            Text(getTextByKey(key: TranslationKey.keySuccessPaymentDescription),
                textAlign: TextAlign.center,
                style: TextStyles.textStyleHelper(context)),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ActionBtn(
          onPressed: () {
            CommonFunctions.pageNumberChalets = 1;
            BlocProvider.of<ChaletsBloc>(context).add(GetAllChaletsEvent(
                pageNumber: CommonFunctions.pageNumberChalets,
                body: const {
                  "page": 1,
                  "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
                  "heightolow": 1,
                  "rateheightolow": 0
                }));
            CommonFunctions.pageNumberBookings = 1;
            if (context.mounted) {
              BlocProvider.of<BookingsBloc>(context)
                  .add(GetAllBookingsEvent(pageNumber: 1, pageSize: 10));
            }
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) =>  const HomePage()),
                  (Route<dynamic> route) => false,
            );
          },
          btnTitle: getTextByKey(key: TranslationKey.keyBack),
          btnColor: primaryColor)
    ]);
  }
}
