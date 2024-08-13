import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/widgets/message_display_widget.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/chalet_detail_page/chalet_detail_widget.dart';

import '../../../../core/util/Constants.dart';
import '../../../../core/widgets/app_bar_back.dart';
import '../../../../core/widgets/loading_widget.dart';

import '../widgets/booking_detail_page/booking_detail_widget.dart';

class BookingDetailPage extends StatelessWidget {

  const BookingDetailPage({
    Key? key,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  appBar: _buildAppbar(),
      body: SafeArea(top: false,child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<BookingsBloc, BookingState>(
      builder: (context, state) {

        if (state is LoadedBookingIdState) {
          print(state.bookingDetails.bookingDays[0].isFullDay);
          return  ListView(
                padding:PADDING_PAGE ,
                children: [
                  const SizedBox(height: 10,),
                AppBarBack(leadingWidgetAction: () {
          Navigator.pop(context);
          }), BookingDetailWidget(bookingDetails: state.bookingDetails),])
          ;
        } else if (state is LoadingBookingIdState) {
          return const LoadingWidget();
        } else {
          return MessageDisplayWidget(message: getTextByKey(key: TranslationKey.keyError));
        }
      },
      buildWhen: (previous, current) =>
      (current is LoadedBookingIdState) || (current is LoadingBookingIdState),
    );
  }
}
