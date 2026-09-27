import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/widgets/app_bar_back.dart';
import 'package:shleehcustomer/features/booking/domain/entities/booking_details_model.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet_details_model.dart';
import '../../../../core/widgets/app_bar_auth.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../widgets/chalet_booking_date/chalet_booking_date_widget.dart';

class ChaletBookingPage extends StatelessWidget {
  final dynamic chalet;
  final bool isChalet;

  const ChaletBookingPage({
    Key? key,
    required this.chalet,
    required this.isChalet
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: true,
      body: SafeArea(child: _buildBody(context,isChalet)),
    );
  }


  Widget _buildBody(BuildContext context , bool isChalet) {
    return SafeArea(
      child: ListView(
          padding:PADDING_PAGE ,
          children: [
        AppBarBack(leadingWidgetAction: () {
          Navigator.pop(context);
        }),
        ChaletBookingDateWidget(chalet: chalet,isChalet:isChalet ,)
      ]),
    );

  }
}
