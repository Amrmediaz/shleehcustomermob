import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/core/widgets/payment_method_badge.dart';
import 'package:shleehcustomer/features/booking/domain/entities/booking_details_model.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalet_detail_page.dart';

import '../../../../../core/util/Constants.dart';
import '../../../../buildings/presentation/widgets/building_detail_page/detail_components/flat_detail_modal.dart';

class BookingDetailWidget extends StatelessWidget {
  final BookingDetails bookingDetails;
  final bool isPendingBooking;
  final bool isChalet;

  const BookingDetailWidget({
    Key? key,
    required this.bookingDetails,
    required this.isPendingBooking,
    required this.isChalet,
  }) : super(key: key);

  double _getOnlinePaymentAmount() {

    // Prefer the new dedicated field, fall back to parsing the legacy
    // "X من Y" string for older bookings.
    final current = bookingDetails.currentPaid;
    if (current != null && current.trim().isNotEmpty) {
      final parsed = double.tryParse(current.trim());
      if (parsed != null) return parsed;
    }
    try {
      String paidStr = bookingDetails.paidAmount.toString();
      if (paidStr.contains('من')) {
        List<String> parts = paidStr.split('من');
        return double.parse(parts[0].trim());
      }
      return double.parse(paidStr);
    } catch (e) {
      return 0.0;
    }
  }

  double _getRemainingAtArrival() {
    final remaining = bookingDetails.remainingPaid;
    if (remaining != null && remaining.trim().isNotEmpty) {
      final parsed = double.tryParse(remaining.trim());
      if (parsed != null) return parsed;
    }
    try {
      String paidStr = bookingDetails.paidAmount.toString();
      if (paidStr.contains('من')) {
        List<String> parts = paidStr.split('من');
        return double.parse(parts[1].trim());
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  double _getInsuranceAmount() {
    try {
      return double.parse(bookingDetails.insuranceAmount.toString());
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final onlinePayment = _getOnlinePaymentAmount();
    final remainingAtArrival = _getRemainingAtArrival();
    final insurance = _getInsuranceAmount();
    // onlinePayment / remainingAtArrival / totalAmount all come straight
    // from the API and already EXCLUDE insurance - the insurance amount
    // is handed directly to the chalet/building owner, not collected
    // online, so it's never part of these. basePrice is just an alias for
    // clarity where the accommodation-only price is meant.
    final totalAmount = onlinePayment + remainingAtArrival;
    final basePrice = totalAmount;
    final isPending = isPendingBooking;
    final hasCustomerEmail = (bookingDetails.customerEmail?.trim().isNotEmpty ?? false);
    final hasCustomerNotes = (bookingDetails.customerNotes?.trim().isNotEmpty ?? false);

    // The grand total shown to the user (accommodation + insurance).
    final double grandTotal = totalAmount + insurance;

    return Directionality(
      textDirection: TextDirection.ltr, // ✅ rtl = index 1
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          getTextByKey(key: TranslationKey.keyBookingDetails),
                          style: TextStyles.textStyleTitle(context).copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#${bookingDetails.id}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Summary Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Booking Info Row 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBadge(
                        icon: Icons.calendar_today_rounded,
                        label: 'عدد الأيام',
                        value: '${bookingDetails.bookingDays.length}',
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      _buildInfoBadge(
                        icon: Icons.date_range_rounded,
                        label: 'تاريخ الحجز',
                        value: bookingDetails.crreatedDate.split('T')[0],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 20),

                  // Price Breakdown
                  _buildPriceRow(
                    label: 'سعر الإقامة',
                    value: '${basePrice.ceil()} ر.ع',
                    isBold: false,
                  ),
                  const SizedBox(height: 12),
                  _buildPriceRow(
                    label: 'التأمين',
                    value: '${insurance.ceil()} ر.ع',
                    isBold: false,
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 16),

                  // Total Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${grandTotal.ceil()} ر.ع',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                  // How this booking was/is being paid — 1 = normal online
                  // payment, 3 = QPay installments. Placed in the always-
                  // rendered Summary Card (rather than the Payment Status
                  // Card below, which only shows when remainingAtArrival >
                  // 0) so it's visible regardless of balance state.
                  if (bookingDetails.paymentType != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PaymentMethodBadge(paymentType: bookingDetails.paymentType),
                    ),
                  ],
                  // QPay installment loan reference — only present once the
                  // booking has actually been confirmed via
                  // BookingQpayConfirm (isLoan true + a non-empty loanId).
                  // Shown so the customer has something concrete to quote
                  // QPay if they need to follow up directly.
                  if (bookingDetails.isLoan == true &&
                      (bookingDetails.loanId ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(DEFAULT_CORNER),
                        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                bookingDetails.loanId!,
                                textDirection: TextDirection.ltr,
                                style: TextStyles.textStyleHelper(context).copyWith(
                                  color: const Color(0xFF7C3AED),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(

                                    getTextByKey(key: TranslationKey.keyQpayLoanIdLabel),

                                    style: TextStyles.textStyleHelper(context).copyWith(
                                      color: const Color(0xFF7C3AED),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.calendar_view_month_rounded,
                                      size: 16, color: Color(0xFF7C3AED)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            getTextByKey(key: TranslationKey.keyQpayLoanIdNote),
                            textDirection: TextDirection.rtl,

                            style: TextStyles.textStyleHelper(context)
                                .copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Contact Info Card (new: customer email + notes)
            if (hasCustomerEmail || hasCustomerNotes) ...[
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'بيانات التواصل',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.contact_mail_rounded,
                          size: 18,
                          color: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (hasCustomerEmail) ...[
                      _buildContactRow(
                        icon: Icons.email_outlined,
                        label: 'البريد الإلكتروني',
                        value: bookingDetails.customerEmail!.trim(),
                      ),
                      if (hasCustomerNotes) const SizedBox(height: 12),
                    ],
                    if (hasCustomerNotes)
                      _buildContactRow(
                        icon: Icons.edit_note_rounded,
                        label: 'ملاحظات',
                        value: bookingDetails.customerNotes!.trim(),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Payment Status Card
            if (remainingAtArrival > 0)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPending
                        ? [
                      primaryColor.withOpacity(0.95),
                      primaryColor.withOpacity(0.85),
                    ]
                        : [
                      Colors.green.withOpacity(0.95),
                      Colors.green.withOpacity(0.85),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isPending ? primaryColor : Colors.green)
                          .withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          isPending ? 'المبلغ المطلوب الآن' : 'تم دفع',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.95),
                          ),
                          textAlign: TextAlign.end,
                        ),
                        if (!isPending) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${onlinePayment.ceil()} ر.ع',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    if (insurance > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'لا يشمل مبلغ التأمين (يُسلَّم لصاحب الشاليه/البناية عند الوصول)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.85),
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            isPending ? 'عند الوصول' : 'متبقي عند الوصول',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.end,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${remainingAtArrival.ceil()} ر.ع',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ── Days List
            if (bookingDetails.bookingDays.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'الأيام المحجوزة',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${bookingDetails.bookingDays.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      bookingDetails.bookingDays.length,
                          (index) {
                        final day = bookingDetails.bookingDays[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: day.isFullDay
                                        ? primaryColor.withOpacity(0.15)
                                        : Colors.amber.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    day.isFullDay ? 'يوم كامل' : 'نصف يوم',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: day.isFullDay
                                          ? primaryColor
                                          : Colors.amber.shade700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    day.day,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ── Action Buttons
            if (isPending)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    remainingAtArrival > 0
                    // ✅ Bank Transfer Button
                        ? _buildActionButton(
                      context,
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'تحويل بنكي',
                      amount: '${onlinePayment.ceil()} ر.ع',
                      onTap: () {
                        CommonFunctions.showBottomWidgetDialog(
                          context,
                          Directionality(
                            textDirection: TextDirection
                                .values[1], // ✅ rtl = index 1
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.account_balance_rounded,
                                    color: primaryColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'تأكيد الحجز بالتحويل البنكي',
                                  style:
                                  TextStyles.textStyleTitle(context),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                // Instructions Box
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.08),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.end,
                                        children: [
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'خطوات التأكيد',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.w700,
                                                color:
                                                Colors.blue.shade700,
                                              ),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          Icon(
                                            Icons.info_rounded,
                                            color: Colors.blue.shade700,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildHintStep(
                                        number: '1',
                                        text:
                                        'قم بتحويل المبلغ ${onlinePayment.ceil()} ر.ع',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildHintStep(
                                        number: '2',
                                        text: 'احفظ إيصال التحويل البنكي',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildHintStep(
                                        number: '3',
                                        text:
                                        'أرسل الإيصال برسالة واتس آب',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // WhatsApp Number Box
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.08),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                      Colors.green.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.copy_rounded,
                                        color: Colors.green.shade700,
                                        size: 18,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'رقم الواتس آب',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green.shade700
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          SelectableText(
                                            '96893866893',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color:
                                              Colors.green.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection
                                .values[1], // ✅ rtl = index 1
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green,
                                        Colors.green.withOpacity(0.85),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      onTap: () {
                                        CommonFunctions
                                            .sendMessageToWhatsApp(
                                          context,
                                          'السلام عليكم\nأريد تأكيد حجزي برقم #${bookingDetails.id}\nسأرسل إيصال التحويل البنكي قريباً',
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.chat_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'فتح واتس آب',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      onTap: () => Navigator.pop(context),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.close_rounded,
                                            color: Colors.grey.shade700,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'إغلاق',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    // ✅ Full Payment Button
                        : _buildActionButton(
                      context,
                      icon: Icons.credit_card_rounded,
                      title: 'ادفع الآن',
                      // basePrice = totalAmount - insurance: the insurance
                      // isn't charged online, it's handed to the owner
                      // directly, so it must not be part of what's
                      // actually sent to the payment gateway below.
                      amount: '${basePrice.ceil()} ر.ع',
                      onTap: () async {


                        final bookingPayload = {
                          "bookingDays": bookingDetails.bookingDays
                              .map((day) => {
                            "day": day.day,
                            "isFullDay": day.isFullDay,
                          })
                              .toList(),
                          "coast": grandTotal.ceil(),
                          "insuranceamount": insurance.toStringAsFixed(0),
                          "paidamount": "${basePrice.ceil()} من 0",
                          "current_paid": "${basePrice.ceil()}",
                          "remaining_paid": "0",
                          "noOFDays": bookingDetails.bookingDays.length,
                          "buildingID": "${bookingDetails.buildingID}",
                          "customerId": "${bookingDetails.customerId}",
                          "name": "${bookingDetails.name}",
                          "phone": "${bookingDetails.phone}",
                          "paymentType": 1,
                          "customer_email": bookingDetails.customerEmail ?? "",
                          "customer_notes": bookingDetails.customerNotes ?? "",
                        };

                        BlocProvider.of<BookingsBloc>(context).add(
                          BookingPaymentChaletEvent(
                              paymentData: {
                                'bookingId': bookingDetails.id,
                                'paymentType': 1,
                                // The actual online charge - excludes
                                // insurance.
                                'amount': basePrice.ceil(),
                                'bookingData': bookingPayload,
                              },
                              isChalet: isChalet
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSecondaryButton(
                      context,
                      icon: Icons.home_rounded,
                      title: getTextByKey(
                        key: isChalet
                            ? TranslationKey.keyDisplayChalet
                            : TranslationKey.keyDisplayFlat,
                      ),
                      onTap: () {
                        if (!isChalet) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => FlatDetailsBottomSheet(
                              flatId: bookingDetails.buildingID,
                              primaryColor: primaryColor,
                              onBook: () => (),
                            ),
                          );
                        } else {
                          BlocProvider.of<ChaletsBloc>(context).add(
                            LoadChaletsById(
                              id: "${bookingDetails.buildingID}",
                            ),
                          );
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: ChaletDetailPage(chaletId: "${bookingDetails.buildingID}"),
                            withNavBar: false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.end,
                ),
                const SizedBox(width: 6),
                Icon(
                  icon,
                  size: 14,
                  color: primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }

  // ── New: full-width row used inside the Contact Info card ───────────
  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.end,
              ),
              const SizedBox(width: 6),
              Icon(
                icon,
                size: 14,
                color: primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
              height: 1.5,
            ),
            textAlign: TextAlign.end,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String value,
    required bool isBold,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            color: Colors.grey.shade900,
          ),
          textAlign: TextAlign.end,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String amount,
        required VoidCallback onTap,
      }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 20), // ✅ RTL compatible
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      amount,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 20), // ✅ RTL compatible
                child: Icon(
                  icon,
                  color: Colors.grey.shade700,
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintStep({
    required String number,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}