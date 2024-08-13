import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shleehcustomer/core/util/enums.dart';
import 'package:shleehcustomer/features/booking/presentation/widgets/chalet_booking/views/payment_method_widget.dart';
import 'package:shleehcustomer/features/booking/presentation/widgets/chalet_booking/views/transfer_account_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/styles/text/text_style.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/cashed_data/cashed_file.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/action_btn.dart';
import '../../../domain/entities/payment.dart';
import '../../bloc/bookings/bookings_bloc.dart';
import '../../pages/payment_bank_screen_web_view.dart';
import '../../pages/sucess_booking_screen.dart';
import '../chalet_booking_date/total_price_Widget.dart';

class BookingChaletForm extends StatefulWidget {
  final PaymentDetails paymentDetails;
  const BookingChaletForm({super.key, required this.paymentDetails});

  @override
  State<BookingChaletForm> createState() => _BookingChaletFormState();
}

List<DateTime?> dates = [];
DateTime currentDate = DateTime.now();
bool isOnlinePayment = true;

class _BookingChaletFormState extends State<BookingChaletForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        Text(
          widget.paymentDetails.chalet.name,
          style: TextStyles.textStyleHelper(context, scaleFactor: 0.7)
              .copyWith(color: Colors.grey.shade500),
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          getTextByKey(key: TranslationKey.keySelectPaymentMethod),
          style: TextStyles.textStyleHeadline(context)
              .copyWith(color: primaryColor),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          getTextByKey(key: TranslationKey.keySelectBookingDateDet),
          style: TextStyles.textStyleBody(context),
        ),
        const SizedBox(
          height: 10,
        ),
        InkWell(
          onTap: () {
            isOnlinePayment = true;
            setState(() {});
          },
          child: PaymentMethodWidget(
            paymentMethod: PaymentMethod.onlineBanking,
            isSelected: isOnlinePayment,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        InkWell(
            onTap: () {
              isOnlinePayment = false;
              setState(() {});
              CommonFunctions.showBottomWidgetDialog(
                  context,
                  Column(
                    children: [
                      Text(
                        "بيانات الحساب البنكي",
                        style: TextStyles.textStyleTitle(context),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "قم بإرسال الإيصال البنكي للرقم الموضح أدناه لتأكيد الحجز",
                        style: TextStyles.textStyleHelper(context),
                      )
                    ],
                  ),
                  const TransferAccountWidget());
            },
            child: PaymentMethodWidget(
              paymentMethod: PaymentMethod.transferBanking,
              isSelected: !isOnlinePayment,
            )),
        const SizedBox(
          height: 20,
        ),
        TotalPriceWidget(
            chalet: widget.paymentDetails.chalet,
            bookingDaysCalculatePrice:
                widget.paymentDetails.bookingDaysCalculatePrice,
            totalBookingPrice: widget.paymentDetails.totalCost , currentPaid: widget.paymentDetails.currentPaid.ceil(),),
        const SizedBox(
          height: 20,
        ),
        BlocListener<BookingsBloc, BookingState>(
            listener: (context, state) {
              if (state is ErrorPaymentBookingState) {
                CommonFunctions.showBottomDialog(context, Icon(Icons.calendar_month_sharp,color: primaryColor,),getTextByKey(key: TranslationKey.keyDatesBooked),getTextByKey(key: TranslationKey.keyPleaseSelectAnotherDates)
                );

              } else if (state is LoadedBookingPaymentState){
                PersistentNavBarNavigator.pushNewScreen(context,
                    screen: PaymentBankWebViewScreen(paymentId: state.url.split("/").last));
                BlocProvider.of<BookingsBloc>(context)
                    .add(BookingsEventIni());
              }
            },child: BlocBuilder<BookingsBloc, BookingState>(

          builder: (context, state) {
            return ActionBtn(
                onPressed: () async {
                  if (isOnlinePayment) {
                    payChalet();
                  } else {
                    await CommonFunctions.sendMessageToWhatsApp( 'اهلا وسهلا ، لقد قمت بحجز شاليه وأريد تأكيد الحجز  \n '
                        " \n Chalet: \n ${widget.paymentDetails.chalet.name} \n \nBooking Number: \n${widget.paymentDetails.bookingId}");
                  }
                },
                btnTitle: getTextByKey(
                    key: isOnlinePayment
                        ? TranslationKey.keyPay
                        : TranslationKey.keyConfirmAccountTransfer),
                btnColor: primaryColor);
          },

          buildWhen: (previous, current) =>
          current is LoadedBookingTotalPriceState ||
              current is LoadingBookingTotalPriceState,
        ))

      ],
    );
  }



  void payChalet() {
      BlocProvider.of<BookingsBloc>(context)
          .add(BookingPaymentChaletEvent(paymentData: {
        "bookingId": widget.paymentDetails.bookingId,
        "paymentType": 1,
      }));

  }
}
