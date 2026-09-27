import '../../domain/entities/booking.dart';

// Parses paymentType defensively — backend may send it as an int, a numeric
// string, or omit it entirely on older/non-online bookings.
int? _parsePaymentType(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  return int.tryParse(raw.toString());
}

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
    required super.itemName,
    super.paymentType,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json , bool isChalet  ) {
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
      bookingDays: List<String>.from(isChalet ? json['bookingDays'] : json['hotelbuildingBookingDays'] ?? []),
      buildingID: isChalet ? json[ 'buildingID'] : json['flatID'],
      customerId: json['customerId'],
      itemName: isChalet ? json['buildingNameEn'] : json['buildingNameAr'],
      paymentType: _parsePaymentType(json['paymentType']),
    );
  }


  Map<String, dynamic> toJson(bool isChalet) {
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
     isChalet ? 'bookingDays' :"hotelbuildingBookingDays": bookingDays,
      'buildingID': buildingID,
      'customerId': customerId,
    };
  }
}