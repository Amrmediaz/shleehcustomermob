import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shleehcustomer/core/network/common_api.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/core/widgets/app_bar_auth.dart';
import 'package:shleehcustomer/core/widgets/bottom_sheets.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/pages/login_page.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:shleehcustomer/features/booking/presentation/widgets/chalet_booking_date/total_price_Widget.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet.dart';
import 'package:shleehcustomer/features/booking/presentation/pages/chalet_booking_date_page.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/util/bottom_sheet_custom.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/util/snackbar_message.dart';
import '../../../../../core/widgets/data_row_widget.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../../../../../core/widgets/shimmer_loading.dart';
import '../../../../authentication/login/presentation/bloc/login/login_bloc.dart';
import '../../../../authentication/login/presentation/bloc/login/login_event.dart';
import '../../../../authentication/login/presentation/bloc/login/login_state.dart';
import '../../../../booking/presentation/pages/book_payment_chalet_screen.dart';
import '../../../../chalets/domain/entities/chalet_details_model.dart';
import '../../../domain/entities/payment.dart';

class ChaletBookingDateWidget extends StatefulWidget {
  final ChaletDetails chalet;

  const ChaletBookingDateWidget({
    Key? key,
    required this.chalet,
  }) : super(key: key);

  @override
  _ChaletBookingDateWidgetState createState() =>
      _ChaletBookingDateWidgetState();
}

List<String> get _listTextTabToggle => ["يوم كامل", "نصف يوم"];
DateTime currentDate = DateTime.now();
var casheFile = CasheFile();

class _ChaletBookingDateWidgetState extends State<ChaletBookingDateWidget> {
  List<DateTime?> dates = [];
  var _tabTextIndexDayTypeSelected = 0;
  var totalCost = 0.0;
  List<String> bookedDates = [];
  List<String> bookedDatesNew = [];

  var isLoadingBookedDates = true;
  var paidAmpunt = 0.0;
  var userEnablleDeposite = false;
  @override
  void initState() {
    // TODO: implement initState
    getBookedDates();
    super.initState();
  }

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
          widget.chalet.name,
          style: TextStyles.textStyleHelper(context, scaleFactor: 0.7)
              .copyWith(color: Colors.grey.shade500),
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          getTextByKey(key: TranslationKey.keySelectBookingDate),
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
          height: 20,
        ),
        FlutterToggleTab(
          width: 90, // width in percent
          borderRadius: 30,
          height: 50,
          selectedIndex: _tabTextIndexDayTypeSelected,
          selectedBackgroundColors: [primaryColor, primaryColor],
          selectedTextStyle: TextStyles.textStyleButton(context),
          unSelectedTextStyle:
              TextStyles.textStyleHelper(context).copyWith(color: Colors.black),
          labels: _listTextTabToggle,
          selectedLabelIndex: (index) {
            setState(() {
              if (widget.chalet.rentHalfday.isNotEmpty) {
                _tabTextIndexDayTypeSelected = index;
                dates.clear();
                bookingDaysCalculatePrice.clear();
                setState(() {});
              }
            });
          },
          isScroll: false,
        ),
        CalendarDatePicker2(
            config: CalendarDatePicker2Config(selectedYearTextStyle: TextStyles.textStyleBody(context) ,
              weekdayLabelTextStyle: TextStyles.textStyleBody(context) ,

              dayTextStyle: TextStyles.textStyleBody(context),
              todayTextStyle: TextStyles.textStyleBody(context),
              disabledDayTextStyle: TextStyles.textStyleBody(context)
                  .copyWith(color: Colors.red.shade200),
              selectedDayTextStyle: TextStyles.textStyleBody(context)
                  .copyWith(color: Colors.white),
              yearTextStyle: TextStyles.textStyleBody(context),
              calendarType: CalendarDatePicker2Type.range,
              firstDate: currentDate.add(const Duration(days: 1)),
              lastDate: currentDate
                  .add(const Duration(days: 1))
                  .add(const Duration(days: 2 * 30)),
              selectableDayPredicate: (value) {
                if (bookedDates
                    .contains(getBookedDatesWithCalendarFormat(value))) {
                  return false;
                } else if (formatDate(value) == formatDate(DateTime.now())) {
                  return false;
                } else {
                  return true;
                }
              },
            ),
            value: dates,
            onValueChanged: (datesValue) {
              dates = datesValue;
              if (datesValue.length > 1) {
                if (isDateInRange(
                    datesValue[0]!, datesValue[1]!, bookedDates)) {

                  BlocProvider.of<BookingsBloc>(context).add(
                      CalculateBookingTotalPriceEvent(
                          dates: convertDateRangeToJsonString(
                              dates, widget.chalet.id)));
                } else {
                  showBookedDialog();
                }
              }
            }),
        bookingDaysCalculatePrice.isNotEmpty
            ? BlocListener<BookingsBloc, BookingState>(
                listener: (context, state) {
                  if (state is ChaletAlreadyBookedState) {
                    showBookedDialog();
                  } else if (state is ChaletBookedSuccessState) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: BookChaletScreen(
                            paymentDetails: PaymentDetails(
                                bookingId: state.bookingId,
                                daysCount: bookingDaysCalculatePrice.length,
                                daysRange: "${dates[0]} - ${dates[1]}",
                                totalCost: totalCost,
                                insurance: widget.chalet.insuranceamount,
                                arbon: widget.chalet.acceptDeposit,
                                chalet: widget.chalet,
                                bookingDaysCalculatePrice:
                                    bookingDaysCalculatePrice ,
                            currentPaid: userEnablleDeposite ? double.parse("${paidAmpunt.ceil()}") : totalCost
                            )));
                  }
                },
                child: BlocBuilder<BookingsBloc, BookingState>(
                  builder: (context, state) {
                    if (state is LoadingBookingTotalPriceState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is LoadedBookingTotalPriceState) {
                      totalCost = state.totalBookingPrice;
                      if (widget.chalet.acceptDeposit && userEnablleDeposite ) {
                        paidAmpunt = (totalCost / 4);
                      } else {
                        paidAmpunt = paidAmpunt;
                      }
                      return Column(
                        children: [
                          TotalPriceWidget(
                            chalet: widget.chalet,
                            bookingDaysCalculatePrice:
                                bookingDaysCalculatePrice,
                            totalBookingPrice: totalCost,
                            currentPaid: userEnablleDeposite ? paidAmpunt.ceil() : totalCost,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          widget.chalet.acceptDeposit
                              ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.all(Radius.circular(12))),
                            child: Row(
                              children: [
                                Checkbox(
                                    value: userEnablleDeposite ,
                                    checkColor: Colors.white,
                                    activeColor: primaryColor,
                                    onChanged: (value) {
                                      userEnablleDeposite = value!;
                                      BlocProvider.of<BookingsBloc>(context).add(
                                          CalculateBookingTotalPriceEvent(
                                              dates: convertDateRangeToJsonString(
                                                  dates, widget.chalet.id)));
                                    }),
                                Flexible(
                                    child: Text(
                                      "دفع عربون(٢٥ ٪) ودفع المبلغ المتبقي عند الوصول",
                                      style: TextStyles.textStyleBody(context),
                                    ))
                              ],
                            ),
                          )
                              : Container()
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                  buildWhen: (previous, current) =>
                      current is LoadedBookingTotalPriceState ||
                      current is LoadingBookingTotalPriceState,
                ))
            : Container(),
        const SizedBox(
          height: 20,
        ),

        const SizedBox(
          height: 10,
        ),
        CasheFile.isLoginUser
            ? ActionBtn(
                onPressed: () async {
                  var expireDate = await casheFile.getUserTokenExpireDate();
                  if (isTokenExpired(expireDate)) {
                    if (context.mounted) {
                      await expireToken(context);
                    }
                  } else {
                    setBookedDays(dates);
                    if (bookedNewlyDays.isNotEmpty && !isLoadingBookedDates) {
                      bookChalet();
                    }
                  }
                },
                btnTitle: getTextByKey(key: TranslationKey.keyBook),
                btnColor: bookingDaysCalculatePrice.isNotEmpty
                    ? primaryColor
                    : Colors.grey.shade500)
            : Column(
                children: [
                  Text(
                    getTextByKey(key: TranslationKey.keyShouldLogin),
                    style: TextStyles.textStyleHeadline(context,
                            titleSizeFactor: 0.65)
                        .copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BlocConsumer<LoginBloc, LoginState>(
                    listener: (context, state) {
                      if (state is MessageLoginState) {
                        if (!state.isMainLogin) {
                          Navigator.pop(context);
                          CommonFunctions.showBottomWidgetDialog(
                              context,
                              Icon(
                                Icons.check_circle_outlined,
                                color: primaryColor,
                                size: MediaQuery.of(context).size.width / 7,
                              ),
                              Column(
                                children: [
                                  Text(
                                    getTextByKey(
                                        key: TranslationKey
                                            .keyLoginSuccessMessage),
                                    style: TextStyles.textStyleHeadline(context,
                                        titleSizeFactor: 0.7),
                                  )
                                ],
                              ));
                          setState(() {});
                        }
                      } else if (state is ErrorLoginState) {
                        if (!state.isMainLogin) {
                          SnackBarMessage().showErrorSnackBar(
                              message: state.message, context: context);
                          CommonFunctions.showBottomDialog(
                              context,
                              Icon(
                                Icons.error,
                                color: primaryColor,
                                size:
                                    CommonFunctions.calculateIconSize(context),
                              ),
                              state.message,
                              "");
                        }
                      }
                    },
                    builder: (context, state) {
                      return ActionBtn(
                          onPressed: () {
                            BottomSheetsCustom.showLoginBottomDialog(context);
                          },
                          btnTitle: getTextByKey(key: TranslationKey.keyLogin),
                          btnColor: primaryColor);
                    },
                  )
                ],
              )
      ],
    );
  }

  void showBookedDialog() {
    CommonFunctions.showBottomDialog(
        context,
        Icon(
          Icons.calendar_month_sharp,
          color: primaryColor,
        ),
        getTextByKey(key: TranslationKey.keyDatesBooked),
        getTextByKey(key: TranslationKey.keyPleaseSelectAnotherDates));
  }

  List<Map<String, dynamic>> bookingDaysCalculatePrice = [];
  // 28/05/2024
  String convertDateRangeToJsonString(
      List<DateTime?> dateRange, int buildingId) {
    if (dateRange.length != 2 || dateRange.any((date) => date == null)) {
      throw ArgumentError('Invalid date range');
    }

    DateTime startDate = dateRange[0]!;
    DateTime endDate = dateRange[1]!;
    print(startDate);
    bookingDaysCalculatePrice = [];
    for (DateTime date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      bookingDaysCalculatePrice.add({
        'day': date.toIso8601String(),
        'fullday': _tabTextIndexDayTypeSelected == 0,
      });
      print("Datex ${date.toUtc().toIso8601String()}");
    }

    dynamic jsonData = {
      'buldingId': buildingId,
      'bookingDays': bookingDaysCalculatePrice,
    };
    setState(() {});
    return jsonEncode(jsonData);
  }

  bool isDateInRange(
      DateTime startDate, DateTime endDate, List<String> bookedDates) {
    for (var dateString in bookedDates) {
      List<String> parts = dateString.split('/');
      if (parts.length == 3) {
        int? day = int.tryParse(parts[0]);
        int? month = int.tryParse(parts[1]);
        int? year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          DateTime bookedDate = DateTime(year, month, day);
          if (bookedDate.isAfter(startDate) && bookedDate.isBefore(endDate)) {
            return false; // A booked date is found within the range
          }
        }
      }
    }
    return true; // No booked date found within the range
  }

  List<Map<String, dynamic>> bookedDays = [];
  var bookedNewlyDays = [];

  getBookedDates() async {
    await CommonApi().getBookedDates(widget.chalet.id).then((value) {
      bookedDates = value;
      isLoadingBookedDates = false;
      setState(() {});
    });
  }

  setBookedDays(List<DateTime?> dateRange) {
    DateTime startDate = dateRange[0]!;
    DateTime endDate = dateRange[1]!;
    bookedNewlyDays = [];

    DateFormat dateFormatter = DateFormat('dd/MM/yyyy','en');
    for (DateTime date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      bookedNewlyDays.add({
        'day': dateFormatter.format(date),
        'isFullDay': _tabTextIndexDayTypeSelected == 0 ? true : false,
      });
    }

  }

  void bookChalet() {

    setBookedDays(dates);

    CasheFile.loadUser().then((user) {
      BlocProvider.of<BookingsBloc>(context)
          .add(BookingChaletEvent(bookingData: {
        "bookingDays":bookedNewlyDays,
        "coast": userEnablleDeposite ? (paidAmpunt + double.parse(widget.chalet.insuranceamount )).ceil() : totalCost + double.parse(widget.chalet.insuranceamount ).ceil() ,
        "insuranceamount": widget.chalet.insuranceamount ?? "",
        "paidamount":  "${(paidAmpunt + double.parse(widget.chalet.insuranceamount )).ceil()} من  ${totalCost}",
        "noOFDays": dates.length,
        "buildingID": widget.chalet.id,
        "customerId": user?.id,
        "name": "${user?.firstName}",
        "note": widget.chalet.rentweekend,
        "phone": "${user?.phoneNumber}",
        "state": "",
        "gouvernate": "",
      }));

    });

  }
}
