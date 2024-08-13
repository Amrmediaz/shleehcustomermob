import 'package:shimmer/shimmer.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/widgets/no_data.dart';
import 'package:shleehcustomer/features/booking/domain/entities/booking.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import '../../../../core/util/common_functions.dart';
import '../../../../core/widgets/message_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../widgets/user_bookings/booking_page_widget.dart';

class UserBookingPage extends StatelessWidget {
  UserBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  List<Booking> bookings = [];
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: BlocBuilder<BookingsBloc, BookingState>(
        builder: (context, state) {
          if (state is LoadingBookingsState) {
            return const ShimmerLoading();
          } else if (state is LoadedBookingsState) {
            if (state.page == 1){
              CommonFunctions.pageNumberBookings = 1;
              bookings.clear();
            }
            bookings.addAll(state.bookings);
            return bookings.isEmpty ? Row(crossAxisAlignment: CrossAxisAlignment.center ,children: [ NoDataWidget()],) : RefreshIndicator(
                onRefresh: () => _onRefresh(context),
                child: BookingsPageWidget(
                  bookings: bookings,
                  bookingStateIsEmpty: state.bookings.isEmpty,
                  buildContext: context,
                ));
          } else if (state is ErrorBookingsState) {
            return MessageDisplayWidget(message: state.message);
          }
          return Shimmer.fromColors(
              baseColor: Colors.grey.shade100,
              highlightColor: Colors.grey.shade200,
              child: const ShimmerLoading());
        },
        buildWhen: (previous, current) => current is LoadedBookingsState,
      ),
    );
  }

  var priceFilter = 1;
  var rateFilter = 0;
  Future<void> _onRefresh(BuildContext context) async {
    CommonFunctions.pageNumberBookings = 1;

    BlocProvider.of<BookingsBloc>(context).add(GetAllBookingsEvent(
        pageNumber: CommonFunctions.pageNumberBookings,
        pageSize: PAGE_SIZE_CHALETS_PAGINATION,
       ));
  }
}
