import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/home_page/presentation/bloc/home/home_bloc.dart';

import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/action_btn.dart';
import '../../../../../core/widgets/loading_image.dart';
import '../../bloc/bookings/bookings_bloc.dart';
import '../../pages/booking_detail_page.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/booking.dart';
import '../../pages/payment_bank_screen_web_view.dart';

class BookingListWidget extends StatelessWidget {
  final List<Booking> bookings;
  final bool lastEmpty;
  BookingListWidget({
    Key? key,
    required this.bookings,
    required this.lastEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool listenerTriggered = false;
    return ListView.separated(
      itemCount: bookings.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        bool isLastItem = index == bookings.length - 1;
        if (isLastItem && !lastEmpty) {
          CommonFunctions.pageNumberBookings =
              CommonFunctions.pageNumberBookings + 1;
          BlocProvider.of<BookingsBloc>(context).add(GetAllBookingsEvent(
              pageNumber: CommonFunctions.pageNumberBookings, pageSize: 10));
        } else {}

        return Material(

            borderRadius:
                const BorderRadius.all(Radius.circular(DEFAULT_CORNER)),
            child: InkWell(
                onTap: () {
                  BlocProvider.of<BookingsBloc>(context)
                      .add(LoadBookingsById(id: "${bookings[index].id}"));

                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const BookingDetailPage(),
                    withNavBar: false,
                  );
                },
                child: AnimatedContainer(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(DEFAULT_CORNER),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "${index + 1}",
                              style: TextStyles.textStyleTitle(context,
                                      titleSizeFactor: 1.3)
                                  .copyWith(color: Colors.grey.shade300),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      "${bookings[index].coast} ${getTextByKey(key: TranslationKey.keyOMR)}",
                                      style: TextStyles.textStyleButton(context)
                                          .copyWith(color: Colors.black)),
                                  Text(
                                    getTextByKey(
                                            key: TranslationKey
                                                .keyBookingNumber) +
                                        bookings[index].id.toString(),
                                    style: TextStyles.textStyleButton(context)
                                        .copyWith(color: yellowAppColor),
                                  ),
                                  isLastItem && !lastEmpty
                                      ? const SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: CircularProgressIndicator(),
                                        )
                                      : Container()
                                ]),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        bookings[index].bookingStatus == 0
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    getTextByKey(
                                        key: TranslationKey.keyPayConfoirm),
                                    style: TextStyles.textStyleHelper(context),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: yellowAppColor),
                                      onPressed: () {
                                        BlocProvider.of<BookingsBloc>(context)
                                            .add(BookingPaymentChaletEvent(
                                            paymentData: {
                                              "bookingId": bookings[index].id,
                                              "paymentType": 1,
                                            }));
                                      },
                                  child:  Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.5,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: yellowAppColor,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(
                                                          DEFAULT_CORNER - 5))),
                                          child: Center(
                                              child: Text(
                                            getTextByKey(
                                                key: TranslationKey.keyPay),
                                            style: TextStyles.textStyleButton(
                                                context),
                                          ))))
                                  ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                    Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(
                                                        DEFAULT_CORNER))),
                                        child: Text(
                                          getTextByKey(
                                              key: TranslationKey.keyConfirmed),
                                          style:
                                              TextStyles.textStyleTitle(context)
                                                  .copyWith(
                                                      color: primaryColor),
                                          textAlign: TextAlign.start,
                                        )),
                                  ]),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ))));
      },
      separatorBuilder: (context, index) => Divider(
        thickness: 1,
        color: Colors.grey.shade200,
      ),
    );
  }
}
