import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shleehcustomer/core/network/common_api.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/today_offer_widgets.dart';
import '../../../../settings/presentation/widgets/settings_widget/support_btn.dart';

import '../../../domain/entities/special_price_range.dart';
import 'booking_instructions_dialog.dart';
import 'chalet_booking_date_components/booking_Calendar.dart';
import 'chalet_booking_date_components/booking_area_button.dart';
import 'chalet_booking_date_components/booking_info_banner.dart';
import 'chalet_booking_date_components/check_in_out_widget.dart';
import 'chalet_booking_date_components/contact_Info_section.dart';
import 'chalet_booking_date_components/day_toggle.dart';
import 'chalet_booking_date_components/price_section.dart';
import 'chalet_booking_date_components/special_prices_banner.dart';
import 'chaletbookingdatehelper.dart';
import 'min_days_alert_dialog.dart';
import 'one_time_flag_helper.dart';



class ChaletBookingDateWidget extends StatefulWidget {
  final dynamic chalet;
  final bool isChalet;

  const ChaletBookingDateWidget({
    Key? key,
    required this.chalet,
    required this.isChalet,
  }) : super(key: key);

  @override
  _ChaletBookingDateWidgetState createState() => _ChaletBookingDateWidgetState();
}

final DateTime currentDate = DateTime.now();
final casheFile = CasheFile();

const String _savedEmailPrefKey = 'shleeh_customer_email';
const String _specialPricesBaseUrl = 'https://shleeh.com/api/Owners';

class _ChaletBookingDateWidgetState extends State<ChaletBookingDateWidget> {
  static const _instructionsSeenFlag = OneTimeFlagHelper('booking_instructions_seen');

  List<DateTime?> dates = [];
  int _tabTextIndexDayTypeSelected = 0;
  double totalCost = 0.0;
  List<String> bookedDates = [];
  List<Map<String, dynamic>> bookingDaysCalculatePrice = [];
  List<Map<String, dynamic>> bookedNewlyDays = [];

  bool isLoadingBookedDates = true;
  double paidAmount = 0.0;
  bool userEnableDeposit = false;

  // Customer contact info (email to receive booking + notes).
  final GlobalKey<FormState> _contactFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  static final RegExp _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  // Special/discounted price days.
  List<SpecialPriceRange> specialPrices = [];
  bool isLoadingSpecialPrices = true;

  bool get _isFullDay => _tabTextIndexDayTypeSelected == 0;
  bool get _halfDayAllowed =>
      widget.chalet.rentHalfday.isNotEmpty && widget.chalet.minDays < 2;

  // ── Today's Offer — owner-controlled, last-minute discount ─────────
  // Only ever applies to the FIRST night of a booking, and only when
  // that first night is literally today (not just "the offer is turned
  // on") — a guest booking three nights starting next week shouldn't get
  // today's discount on any of them. Mirrors the website's day-1-only
  // rule (see TODAY-OFFER-API-SPEC.md).
  bool get _offerAppliesToSelection {
    if (widget.chalet.todayOfferActive != true) return false;
    if (dates.isEmpty || dates[0] == null) return false;
    if (!_isFullDay) return false; // half-day bookings aren't covered.
    return _isSameCalendarDay(dates[0]!, currentDate);
  }

  double get _baseNightlyRate {
    if (widget.isChalet) {
      return double.tryParse(widget.chalet.rentFullday.toString()) ?? 0.0;
    }
    final perNight = widget.chalet.price_per_night;
    return perNight is num ? perNight.toDouble() : 0.0;
  }

  double get _todayOfferDiscountAmount {
    if (!_offerAppliesToSelection) return 0.0;
    final percent = widget.chalet.todayOfferPercent;
    if (percent is! int || percent <= 0) return 0.0;
    return _baseNightlyRate * percent / 100;
  }
  @override
  void initState() {
    super.initState();
    getBookedDates();
    _fetchSpecialPrices();
    _loadSavedEmail();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showBookingInstructionsOnce());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ── Saved email ──────────────────────────────────────────────────

  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_savedEmailPrefKey);
      if (saved != null && saved.isNotEmpty && mounted) {
        setState(() => _emailController.text = saved);
      }
    } catch (_) {
      // Ignore - worst case the user just retypes their email.
    }
  }

  Future<void> _saveEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty || !_emailRegExp.hasMatch(trimmed)) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedEmailPrefKey, trimmed);
    } catch (_) {
      // Non-critical, ignore.
    }
  }

  // ── Special/discounted price days ───────────────────────────────

  Future<void> _fetchSpecialPrices() async {
    try {
      final uri = widget.isChalet
          ? Uri.parse('$_specialPricesBaseUrl/GetBuildingPrices?BuldingId=${widget.chalet.id}')
          : Uri.parse('$_specialPricesBaseUrl/GetFlatSpcialPrices?FlatID=${widget.chalet.id}');

      final response = await http.get(uri, headers: {'accept': '*/*'}).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['status'] == true && decoded['message'] is List) {
          final List list = decoded['message'];
          final parsed = <SpecialPriceRange>[];
          for (final item in list) {
            final start = parseApiDate(item['startDate'] as String?);
            final end = parseApiDate(item['endDate'] as String?);
            if (start == null || end == null) continue;
            parsed.add(SpecialPriceRange(
              start: start,
              end: end,
              price: item['price'] is num
                  ? (item['price'] as num).toDouble()
                  : double.tryParse('${item['price']}') ?? 0,
              type: item['type'] is int ? item['type'] as int : int.tryParse('${item['type']}') ?? 0,
            ));
          }
          specialPrices = parsed;
        }
      }
    } catch (_) {
      // Special prices are a nice-to-have; never block booking on this failing.
    } finally {
      isLoadingSpecialPrices = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _showBookingInstructionsOnce() async {
    try {
      final alreadySeen = await _instructionsSeenFlag.hasBeenSeen();
      if (!alreadySeen && mounted) {
        await BookingInstructionsDialog.show(context);
        await _instructionsSeenFlag.markAsSeen();
      }
    } catch (_) {
      // Fallback: just show the dialog if reading/writing prefs fails.
      if (mounted) BookingInstructionsDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            widget.chalet.name,
            style: TextStyles.textStyleHelper(context, scaleFactor: 0.7)
                .copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 15),
          Text(
            getTextByKey(key: TranslationKey.keySelectBookingDate),
            style: TextStyles.textStyleHeadline(context).copyWith(color: primaryColor),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 20),
          Text(
            getTextByKey(key: TranslationKey.keySelectBookingDateDet),
            style: TextStyles.textStyleBody(context),
            textAlign: TextAlign.end,
          ),

          if (widget.chalet.todayOfferActive == true) ...[
            const SizedBox(height: 16),
            TodayOfferBanner(
              percent: widget.chalet.todayOfferPercent,
              subtitle: 'اختر اليوم كتاريخ وصول لتحصل على الخصم على أول ليلة',
            ),
          ],
          const SizedBox(height: 16),
          widget.isChalet
              ? const BookingInfoBanner(
            icon: Icons.account_balance_rounded,
            color: Colors.amber,
            text: 'اذا اخترت دفع 25% عربون، ستجد بيانات التحويل البنكي في تفاصيل الحجز',
          )
              : Container(),
          const SizedBox(height: 20),
          SpecialPricesBanner(specialPrices: specialPrices, isLoading: isLoadingSpecialPrices),
          const SizedBox(height: 20),
          DayTypeToggle(
            selectedIndex: _tabTextIndexDayTypeSelected,
            onChanged: (index) {
              if (index == 1 && !_halfDayAllowed) {
                CommonFunctions.showBottomDialog(
                  context,
                  icon: Icon(Icons.info_outline_rounded, color: primaryColor),
                  title: 'نص اليوم غير متاح',
                  description:
                  'الحد الأدنى للحجز في هذا الشاليه ${widget.chalet.minDays} أيام، لذلك خيار نص اليوم غير متاح.',
                );
                return;
              }

              if (widget.chalet.rentHalfday.isNotEmpty) {
                setState(() {
                  _tabTextIndexDayTypeSelected = index;
                  dates.clear();
                  bookingDaysCalculatePrice.clear();
                });
              }
            },
          ),
          const SizedBox(height: 20),
          BookingCalendar(
            value: dates,
            bookedDates: bookedDates,
            specialPrices: specialPrices,
            currentDate: currentDate,
            isFullDay: _isFullDay, // جديد
            onValueChanged: _onCalendarValueChanged,
          ),
          const SizedBox(height: 16),
          CheckInOutSummary(dates: dates,isFullDay: _isFullDay,),
          const SizedBox(height: 16),
          PriceSection(
            bookingDaysCalculatePrice: bookingDaysCalculatePrice,
            chalet: widget.chalet,
            isChalet: widget.isChalet,
            dates: dates,
            userEnableDeposit: userEnableDeposit,
            onDepositChanged: _onDepositChanged,
            onPriceCalculated: (total, paid) {
              totalCost = total;
              paidAmount = paid;
            },
            onAlreadyBooked: showBookedDialog,
          ),
          if (_todayOfferDiscountAmount > 0) ...[
            const SizedBox(height: 10),
            _buildOfferDiscountRow(),
          ],
          const SizedBox(height: 20),
          ContactInfoSection(
            formKey: _contactFormKey,
            emailController: _emailController,
            notesController: _notesController,
            emailRegExp: _emailRegExp,
            onEmailChanged: _saveEmail,
          ),
          const SizedBox(height: 10),
          _buildBookButtonArea(context),
          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SupportBtn(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Shown right under the price breakdown once the guest's selected
  /// check-in date is actually today, so the discount amount is concrete
  /// and tied to their real selection rather than a generic promo line.
  /// Deliberately doesn't try to show a running "total after discount" —
  /// PriceSection/TotalPriceWidget owns that display and is fed by the
  /// bloc directly; duplicating it here from this widget's cached
  /// `totalCost` risks showing a stale number if it updates out of sync.
  Widget _buildOfferDiscountRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        // Light tint of the same green as the website's Today's Offer
        // badge/note (#1E8E5A / #146945), not the old orange scheme.
        color: TodayOfferColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TodayOfferColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded,
              color: TodayOfferColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'وفّرت ${_todayOfferDiscountAmount.toStringAsFixed(2)} ${getTextByKey(key: TranslationKey.keyOMR)} بخصم عرض اليوم على أول ليلة',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: TodayOfferColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Calendar / price recalculation ─────────────────────────────────

  void _onCalendarValueChanged(List<DateTime?> datesValue) {
    dates = datesValue;

    if (_isFullDay) {
      if (datesValue.length == 2 && datesValue[0] != null && datesValue[1] != null) {
        if (_isSameCalendarDay(datesValue[0]!, datesValue[1]!)) {
          _showCheckInCheckOutRequiredDialog();
          dates.clear();
          bookingDaysCalculatePrice.clear();
          setState(() {});
          return;
        }

        final available = ChaletBookingDateHelper.isDateRangeAvailable(
          startDate: datesValue[0]!,
          endDate: datesValue[1]!,
          bookedDates: bookedDates,
        );

        if (available) {
          _recalculatePrice();
        } else {
          showBookedDialog();
          dates.clear();
        }
      }
    } else {
      // نص يوم: تاريخ واحد كافي ويعتبر حجز مكتمل
      if (datesValue.length == 1 && datesValue[0] != null) {
        final selected = datesValue[0]!;
        final available = ChaletBookingDateHelper.isDateRangeAvailable(
          startDate: selected,
          endDate: selected,
          bookedDates: bookedDates,
        );

        if (available) {
          _recalculatePrice();
        } else {
          showBookedDialog();
          dates.clear();
        }
      }
    }

    setState(() {});
  }

  void _recalculatePrice() {
    final result = ChaletBookingDateHelper.convertDateRangeToJsonString(
      dateRange: dates,
      buildingId: widget.isChalet ? widget.chalet.id : widget.chalet.id,
      isChalet: widget.isChalet,
      isFullDay: _isFullDay,
    );
    bookingDaysCalculatePrice = result.bookingDaysCalculatePrice;

    BlocProvider.of<BookingsBloc>(context).add(
      CalculateBookingTotalPriceEvent(dates: result.jsonPayload, isChalet: widget.isChalet),
    );
  }
  bool _isSameCalendarDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _onDepositChanged(bool value) {
    setState(() => userEnableDeposit = value);

    final result = ChaletBookingDateHelper.convertDateRangeToJsonString(
      dateRange: dates,
      buildingId: widget.isChalet ? widget.chalet.id : widget.chalet.typeId,
      isChalet: widget.isChalet,
      isFullDay: _isFullDay,
    );
    bookingDaysCalculatePrice = result.bookingDaysCalculatePrice;
    BlocProvider.of<BookingsBloc>(context).add(
      CalculateBookingTotalPriceEvent(dates: result.jsonPayload, isChalet: widget.isChalet),
    );
  }

  // ── Book button / login ─────────────────────────────────────────────

  Widget _buildBookButtonArea(BuildContext context) {
    return BookButtonArea(
      isLoggedIn: CasheFile.isLoginUser,
      canBook: bookingDaysCalculatePrice.isNotEmpty,
      onBookPressed: _onBookPressed,
      onLoginSuccess: () => setState(() {}),
    );
  }

  Future<void> _onBookPressed() async {
    final expireDate = await casheFile.getUserTokenExpireDate();
    if (isTokenExpired(expireDate)) {
      if (context.mounted) await expireToken(context);
      return;
    }

    // Validate the contact info (email / notes) before proceeding.
    if (_contactFormKey.currentState?.validate() != true) {
      return;
    }

    bookedNewlyDays = ChaletBookingDateHelper.buildBookedDaysPayload(
      dateRange: dates,
      isFullDay: _isFullDay,
    );

    if (bookedNewlyDays.isNotEmpty && !isLoadingBookedDates) {
      bookChalet();
    }
  }

  // ── Dialogs ─────────────────────────────────────────────────────────

  void showBookedDialog() {
    CommonFunctions.showBottomDialog(
      context,
      icon: Icon(Icons.calendar_month_sharp, color: primaryColor),
      title: getTextByKey(key: TranslationKey.keyDatesBooked),
      description: getTextByKey(key: TranslationKey.keyPleaseSelectAnotherDates),
    );
  }

  void _showCheckInCheckOutRequiredDialog() {
    CommonFunctions.showBottomDialog(
      context,
      icon: Icon(Icons.event_repeat_rounded, color: primaryColor),
      title: 'لازم تختار تاريخ وصول وتاريخ مغادرة مختلفين',
      description: 'برجاء اختيار تاريخ وصول، ثم تاريخ مغادرة مختلف عنه لإتمام الحجز',
    );
  }

  void _showMinDaysAlert(String minDays) => MinDaysAlertDialog.show(context, minDays);

  // ── Data loading / booking ────────────────────────────────────────

  Future<void> getBookedDates() async {
    try {
      final value = await CommonApi().getBookedDates(widget.chalet.id, widget.isChalet);
      bookedDates = value;
    } catch (e) {
      // Network/SSL hiccup (e.g. flaky mobile connection) — don't leave the
      // calendar stuck on its loading state forever; just show it with
      // whatever booked dates we have (none) so the user can retry/continue.
      print('❌ getBookedDates network error: $e');
      if (mounted) {
        CommonFunctions.showBottomDialog(
          context,
          icon: Icon(Icons.wifi_off_rounded, color: primaryColor),
          title: getTextByKey(key: TranslationKey.keyNoInternet),
          description: getTextByKey(key: TranslationKey.keyNoInternet),
        );
      }
    } finally {
      isLoadingBookedDates = false;
      if (mounted) setState(() {});
    }
  }

  void bookChalet() {
    bookedNewlyDays = ChaletBookingDateHelper.buildBookedDaysPayload(
      dateRange: dates,
      isFullDay: _isFullDay,
    );

    _saveEmail(_emailController.text);

    CasheFile.loadUser().then((user) {
      final double insurance = widget.chalet.insuranceamount is double
          ? widget.chalet.insuranceamount
          : double.tryParse(widget.chalet.insuranceamount) ?? 0.0;

      // Apply Today's Offer (day-1-only) before deposit math, so a 25%
      // deposit is calculated on the already-discounted total rather than
      // the full price. Recomputed here (not read from build()) since this
      // runs inside an async callback where the discount must still match
      // exactly what was shown to the guest.
      final double offerDiscount = _todayOfferDiscountAmount;
      final double discountedTotal = totalCost - offerDiscount;
      final double total = discountedTotal < 0 ? 0.0 : discountedTotal;

      double remainingAtArrival;
      if (widget.chalet.acceptDeposit && userEnableDeposit) {
        paidAmount = (total * 0.25).ceilToDouble();
        remainingAtArrival = total - paidAmount;
      } else {
        paidAmount = total;
        remainingAtArrival = 0.0;
      }

      if (widget.chalet.minDays > bookingDaysCalculatePrice.length) {
        _showMinDaysAlert(widget.chalet.minDays.toString());
        return;
      }

      final bookingData = {
        widget.isChalet ? "bookingDays" : "hotelbuildingBookingDays": bookedNewlyDays,
        "coast": widget.isChalet ? paidAmount : total.ceil(),
        "insuranceamount": insurance.toString(),
        "paidamount": "${paidAmount.ceil()} من ${remainingAtArrival.ceil()}",
        "current_paid": "${paidAmount.ceil()}",
        "remaining_paid": "${remainingAtArrival.ceil()}",
        "noOFDays": bookingDaysCalculatePrice.length,
        widget.isChalet ? "buildingID" : "flatID": widget.chalet.id,
        "customerId": user?.id,
        "name": "${user?.firstName}",
        "note": widget.isChalet ? widget.chalet.rentweekend : widget.chalet.managmentPhone,
        "phone": "${user?.phoneNumber}",
        "state": "",
        "gouvernate": "",
        "customer_email": _emailController.text.trim(),
        "customer_notes": _notesController.text.trim(),
        // Today's Offer — tells the backend a last-minute discount was
        // applied to this booking (and how much), mirroring how the
        // website reports it (see TODAY-OFFER-API-SPEC.md), so the
        // backend can validate/record it rather than trusting the client
        // total alone.
        "todayOfferApplied": offerDiscount > 0,
        "todayOfferPercent": offerDiscount > 0 ? widget.chalet.todayOfferPercent : 0,
        "todayOfferDiscountAmount": offerDiscount,
      };

      BlocProvider.of<BookingsBloc>(context).add(
        BookingChaletEvent(bookingData: bookingData, isChalet: widget.isChalet),
      );

      print("booking  $bookingData");
    });
  }
}