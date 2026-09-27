import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_details_model.dart';

// Parses paymentType defensively — backend may send it as an int, a
// numeric string, or omit it entirely on older/non-online bookings.
int? _parsePaymentType(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  return int.tryParse(raw.toString());
}

class BookingDetailsModel extends BookingDetails {
  final int id;
  final String name;
  final String phone;
  final String state;
  final String gouvernate;
  final dynamic coast;
  final int noOfDays;
  final String? note;
  final String? insuranceAmount;
  final String paidAmount;
  final List<BookingDay> bookingDays;
  final double? buildingRate;
  final int buildingID;
  final int customerId;
  final String crreatedDate;

  // ── New fields ──────────────────────────────────────────────────────
  final String? currentPaid;
  final String? remainingPaid;
  final String? customerNotes;
  final String? customerEmail;
  final int? paymentType;
  final bool? isLoan;
  final String? loanId;

  BookingDetailsModel({
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
  }) : super(
    id: id,
    name: name,
    phone: phone,
    state: state,
    gouvernate: gouvernate,
    coast: coast,
    noOfDays: noOfDays,
    note: note,
    crreatedDate: crreatedDate,
    insuranceAmount: insuranceAmount,
    paidAmount: paidAmount,
    bookingDays: bookingDays,
    buildingRate: buildingRate,
    buildingID: buildingID,
    customerId: customerId,
    currentPaid: currentPaid,
    remainingPaid: remainingPaid,
    customerNotes: customerNotes,
    customerEmail: customerEmail,
    paymentType: paymentType,
    isLoan: isLoan,
    loanId: loanId,
  );

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json, bool isChalet) {
    return BookingDetailsModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      state: json['state'],
      gouvernate: json['gouvernate'],
      coast: json['coast'],
      noOfDays: json['noOFDays'],
      note: json['note'],
      crreatedDate: json['crreatedDate'],
      insuranceAmount: json['insuranceamount'],
      paidAmount: json['paidamount'],
      bookingDays: List<BookingDay>.from(
          json[isChalet ? 'bookingDays' : "hotelbuildingBookingDays"].map((item) => BookingDay.fromJson(item))),
      buildingRate:
      json['buildingRate'] != null ? json['buildingRate'].toDouble() : null,
      buildingID: isChalet ? json['buildingID'] : json['flatID'],
      customerId: json['customerId'],
      currentPaid: json['current_paid'],
      remainingPaid: json['remaining_paid'],
      customerNotes: json['customer_notes'],
      customerEmail: json['customer_email'],
      paymentType: _parsePaymentType(json['paymentType']),
      isLoan: json['isLoan'] as bool?,
      loanId: json['loanId']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'phone': phone,
      'coast': coast,
      'noOFDays': noOfDays,
      'insuranceamount': insuranceAmount,
      'paidamount': paidAmount,
      'bookingDays': bookingDays.map((item) => item.toJson()).toList(),
      'buildingRate': buildingRate,
      'buildingID': buildingID,
      'customerId': customerId,
      'current_paid': currentPaid,
      'remaining_paid': remainingPaid,
      'customer_notes': customerNotes,
      'customer_email': customerEmail,
    });
    return json;
  }
}

class BookingDay {
  final String day;
  final bool isFullDay;

  BookingDay({
    required this.day,
    required this.isFullDay,
  });

  factory BookingDay.fromJson(Map<String, dynamic> json) {
    return BookingDay(
      day: json['day'],
      isFullDay: json['isFullDay'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'isFullDay': isFullDay,
    };
  }
}