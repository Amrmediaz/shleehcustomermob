 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shleehcustomer/features/booking/presentation/widgets/chalet_booking/booking_chalet.dart';

import '../../../../core/util/Constants.dart';
import '../../../../core/widgets/app_bar_back.dart';
import '../../domain/entities/payment.dart';


class BookChaletScreen extends StatelessWidget {
  final PaymentDetails paymentDetails;
  final bool isChalet;
   const BookChaletScreen({super.key,
   required this.paymentDetails ,
     required this.isChalet

  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody(context)),
    );
  }



  Widget _buildBody(BuildContext context) {
    return ListView(
        padding:PADDING_PAGE ,
        children: [
          AppBarBack(leadingWidgetAction: () {
            Navigator.pop(context);
          }),
           BookingChaletForm(paymentDetails: paymentDetails, isChalet: isChalet)
        ]);
  
  }
}
