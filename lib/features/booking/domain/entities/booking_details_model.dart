// Keep whatever import already gives you `BookingDay` here — in your
// pasted model that was `import '../../domain/entities/booking.dart';`.
// import 'booking.dart';

import '../../data/models/booking_details.dart';

/// Domain entity — replace the contents of
/// `../../domain/entities/booking_details_model.dart` with this.
class BookingDetails {
    final int id;
    final String name;
    final String phone;
    final String state;
    final String gouvernate;
    final dynamic coast;
    final int noOfDays;
    final String? note;
    final String crreatedDate;
    final String? insuranceAmount;
    final String paidAmount;
    final List<BookingDay> bookingDays;
    final double? buildingRate;
    final int buildingID;
    final int customerId;

    // ── New fields ──────────────────────────────────────────────────────
    final String? currentPaid;
    final String? remainingPaid;
    final String? customerNotes;
    final String? customerEmail;
    // 1 = normal online bank payment, 3 = QPay installments — same values
    // sent to BookingPayment/BookingPaymentQpay. Nullable since older or
    // non-online (WhatsApp transfer confirmation) bookings may not have it.
    final int? paymentType;
    // QPay installment loan reference — present once a booking has been
    // confirmed via BookingQpayConfirm. When isLoan is true and loanId is
    // non-empty, the details page shows it so the customer can follow up
    // with QPay directly using that id.
    final bool? isLoan;
    final String? loanId;

    BookingDetails({
        required this.id,
        required this.name,
        required this.phone,
        required this.state,
        required this.gouvernate,
        required this.coast,
        required this.noOfDays,
        this.note,
        required this.crreatedDate,
        this.insuranceAmount,
        required this.paidAmount,
        required this.bookingDays,
        this.buildingRate,
        required this.buildingID,
        required this.customerId,
        this.currentPaid,
        this.remainingPaid,
        this.customerNotes,
        this.customerEmail,
        this.paymentType,
        this.isLoan,
        this.loanId,
    });

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'state': state,
            'gouvernate': gouvernate,
            'note': note,
            'crreatedDate': crreatedDate,
        };
    }
}