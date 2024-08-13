import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  BookingModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.state,
    required super.governorate,
    required super.coast,
    required super.noOfDays,
    required super.note,
    required super.createdDate,
    required super.bookingStatus,
    required super.bookingDays,
    required super.buildingID,
    required super.customerId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      state: json['state'],
      governorate: json['gouvernate'],
      coast: json['coast'],
      noOfDays: json['noOFDays'],
      note: json['note'],
      createdDate: json['crreatedDate'],
      bookingStatus: json['bookingstatus'],
      bookingDays: List<String>.from(json['bookingDays']),
      buildingID: json['buildingID'],
      customerId: json['customerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'state': state,
      'gouvernate': governorate,
      'coast': coast,
      'noOFDays': noOfDays,
      'note': note,
      'crreatedDate': createdDate,
      'bookingstatus': bookingStatus,
      'bookingDays': bookingDays,
      'buildingID': buildingID,
      'customerId': customerId,
    };
  }
}