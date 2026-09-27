import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
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
import '../../pages/qpay_checkout_screen.dart';
import '../../pages/sucess_booking_screen.dart';
import '../chalet_booking_date/total_price_Widget.dart';

class BookingChaletForm extends StatefulWidget {
  final PaymentDetails paymentDetails;
  final bool isChalet;
  const BookingChaletForm({super.key, required this.paymentDetails , required this.isChalet});

  @override
  State<BookingChaletForm> createState() => _BookingChaletFormState();
}

List<DateTime?> dates = [];
DateTime currentDate = DateTime.now();
bool isOnlinePayment = true;
// Separate tri-state selection for the 3 payment-method rows — kept
// distinct from the isOnlinePayment/transfer bool pair above (which stay
// mutually exclusive with each other only) so adding QPay as a third
// option doesn't make Transfer show as selected whenever QPay is picked.
PaymentMethod _selectedMethod = PaymentMethod.onlineBanking;

class _BookingChaletFormState extends State<BookingChaletForm> {
  @override
  Widget build(BuildContext context) {
    // The 25% deposit is decided on the calendar screen before this one —
    // by the time we're here, currentPaid < totalCost means the guest is
    // only paying the deposit now. Installments require paying the full
    // amount, so QPay isn't a valid combination with that.
    final bool isDepositSelected =
        widget.paymentDetails.currentPaid < widget.paymentDetails.totalCost;
    // Defensive: _selectedMethod is a module-level variable (pre-existing
    // pattern, not scoped to this widget instance), so if a previous
    // booking left it on qpay and this one has the deposit active, fall
    // back to online banking rather than silently keeping an
    // impossible-to-select-but-still-"selected" QPay row.
    if (isDepositSelected && _selectedMethod == PaymentMethod.qpay) {
      _selectedMethod = PaymentMethod.onlineBanking;
    }

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
            _selectedMethod = PaymentMethod.onlineBanking;
            setState(() {});
          },
          child: PaymentMethodWidget(
            paymentMethod: PaymentMethod.onlineBanking,
            isSelected: _selectedMethod == PaymentMethod.onlineBanking,

          ),
        ),
        const SizedBox(
          height: 20,
        ),
        // QPay — installments. A distinct 3rd option next to the existing
        // bank payment above; tapping it doesn't open the WhatsApp/transfer
        // sheet like Transfer below, it just marks itself selected — the
        // actual navigation into the QPay flow happens from the ActionBtn.
        // Disabled when the 25% deposit is active — installments always
        // charge the full amount, so the two can't be combined.
        IgnorePointer(
          ignoring: isDepositSelected,
          child: InkWell(
            onTap: () {
              _selectedMethod = PaymentMethod.qpay;
              setState(() {});
            },
            child: PaymentMethodWidget(
              paymentMethod: PaymentMethod.qpay,
              isSelected: _selectedMethod == PaymentMethod.qpay,
              isDisabled: isDepositSelected,
            ),
          ),
        ),
        if (isDepositSelected) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              getTextByKey(key: TranslationKey.keyQpayNotAvailableWithDeposit),
              style: TextStyles.textStyleHelper(context, scaleFactor: 0.4)
                  .copyWith(color: Colors.grey.shade500),
            ),
          ),
        ],
        const SizedBox(
          height: 20,
        ),
        InkWell(
            onTap: () {
              isOnlinePayment = false;
              _selectedMethod = PaymentMethod.transferBanking;
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
              isSelected: _selectedMethod == PaymentMethod.transferBanking,
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
        BlocBuilder<BookingsBloc, BookingState>(
          builder: (context, state) {
            return ActionBtn(
              onPressed: () async {
                if (_selectedMethod == PaymentMethod.qpay) {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: QpayCheckoutScreen(
                      bookingId: widget.paymentDetails.bookingId,
                      isChalet: widget.isChalet,
                      totalPrice: widget.paymentDetails.totalCost,
                    ),
                    withNavBar: false,
                  );
                } else if (_selectedMethod == PaymentMethod.onlineBanking) {
                  payChalet();
                } else {
                  // Include the logged-in customer's name + WhatsApp number
                  // in the confirmation message so the owner receiving it
                  // on WhatsApp knows who's booking without asking.
                  final userProfile = await CasheFile.loadUser();
                  final customerName = userProfile != null
                      ? '${userProfile.firstName} ${userProfile.lastName}'.trim()
                      : '';
                  final customerPhone = userProfile?.phoneNumber ?? '';
                  await CommonFunctions.sendMessageToWhatsApp(
                    context,
                    'اهلا وسهلا ، لقد قمت بحجز  وأريد تأكيد الحجز  \n '
                        "${customerName.isNotEmpty ? '\nالاسم: $customerName' : ''}"
                        "${customerPhone.isNotEmpty ? '\nرقم الواتساب: $customerPhone' : ''}"
                        " \n Chalet: \n ${widget.paymentDetails.chalet.name} \n \nBooking Number: \n${widget.paymentDetails.bookingId}",
                  );
                }
              },
              btnTitle: getTextByKey(
                key: _selectedMethod == PaymentMethod.qpay
                    ? TranslationKey.keyQpayContinue
                    : _selectedMethod == PaymentMethod.onlineBanking
                        ? TranslationKey.keyPay
                        : TranslationKey.keyConfirmAccountTransfer,
              ),
              btnColor: primaryColor,
            );
          },
          buildWhen: (previous, current) =>
          current is LoadedBookingTotalPriceState || current is LoadingBookingTotalPriceState,
        )

      ],
    );
  }



  void payChalet() {
      BlocProvider.of<BookingsBloc>(context)
          .add(BookingPaymentChaletEvent(paymentData: {
        "bookingId": widget.paymentDetails.bookingId,
        "paymentType": 1,
      } , isChalet: widget.isChalet));

  }
}
