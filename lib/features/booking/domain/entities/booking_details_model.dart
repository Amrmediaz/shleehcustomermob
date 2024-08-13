import '../../data/models/booking_details.dart';


class BookingDetails {
    int id;
    String name;
    String phone;
    String state;
    String gouvernate;
    dynamic coast;
    int noOfDays;
    String? note;
    String crreatedDate;
    String? insuranceAmount;
    String paidAmount;
    List<BookingDay> bookingDays;
    double? buildingRate;
    int buildingID;
    int customerId;

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
    });

    factory BookingDetails.fromJson(Map<String, dynamic> json) {
        return BookingDetails(
            id: json['id'],
            name: json['name'],
            phone: json['phone'],
            state: json['state'] ?? '',
            gouvernate: json['gouvernate'] ?? '',
            coast: json['coast'].toDouble(),
            noOfDays: json['noOFDays'],
            note: json['note'],
            crreatedDate: json['crreatedDate'],
            insuranceAmount: json['insuranceamount'],
            paidAmount: json['paidamount'],
            bookingDays: List<BookingDay>.from(json['bookingDays'].map((item) => BookingDay.fromJson(item))),
            buildingRate: json['buildingRate'] != null ? json['buildingRate'].toDouble() : null,
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
            'gouvernate': gouvernate,
            'coast': coast,
            'noOFDays': noOfDays,
            'note': note,
            'crreatedDate': crreatedDate,
            'insuranceamount': insuranceAmount,
            'paidamount': paidAmount,
            'bookingDays': bookingDays.map((item) => item.toJson()).toList(),
            'buildingRate': buildingRate,
            'buildingID': buildingID,
            'customerId': customerId,
        };
    }
}




