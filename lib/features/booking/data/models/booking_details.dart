import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_details_model.dart';

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
        );

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) {
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
          json['bookingDays'].map((item) => BookingDay.fromJson(item))),
      buildingRate:
          json['buildingRate'] != null ? json['buildingRate'].toDouble() : null,
      buildingID: json['buildingID'],
      customerId: json['customerId'],
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
