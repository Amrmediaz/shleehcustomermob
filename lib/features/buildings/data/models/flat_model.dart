import 'package:shleehcustomer/features/buildings/domain/entities/flat.dart';

import '../../domain/entities/building.dart';

import '../../domain/entities/building.dart';

class FlatModel extends Flat {
  final String flatNumber;
  final String flatFloor;
  final String bedsNumber;
   bool acceptDeposit  = false;
  final String balconiesNumber;
  final String bathroomsNumber;
  final double? price_per_night;
  final double? weekend_price_per_night;
  final int flatType;
  final String? rentPriceDescription;
  final String? note;
  final int hotelBuildingId;
  final String image;
  final String name;
  final double? insuranceamount ;
  final int typeId;
   String managmentPhone;

  FlatModel({
    required int id,
    required this.name,
    required this.insuranceamount,
    required this.flatNumber,
    required this.flatFloor,
    required this.bedsNumber,
    required this.balconiesNumber,
    required this.bathroomsNumber,
    this.price_per_night,
    this.weekend_price_per_night,
    required this.flatType,
    this.rentPriceDescription,
    this.note,

    required this.hotelBuildingId,
    required this.image, required this.typeId,
    required this.managmentPhone,
    bool todayOfferEnabled = false,
    int todayOfferPercent = 0,
    int todayOfferTriggerHour = 12,
    bool todayOfferActive = false,
  }) : super(
    id: id,
    minDays: 0,
    nameAr: name,
    flatNumber: flatNumber,
    flatFloor: flatFloor,
    bedsNumber: bedsNumber,
    balconiesNumber: balconiesNumber,
    bathroomsNumber: bathroomsNumber,
    price_per_night: price_per_night,
    weekend_price_per_night: weekend_price_per_night,
    flatType: flatType,
    rentPriceDescription: rentPriceDescription,
    note: note,
    hotelBuildingId: hotelBuildingId,
    coverimg: image,
    managmentPhone: managmentPhone,
    todayOfferEnabled: todayOfferEnabled,
    todayOfferPercent: todayOfferPercent,
    todayOfferTriggerHour: todayOfferTriggerHour,
    todayOfferActive: todayOfferActive,
  );

  factory FlatModel.fromJson(Map<String, dynamic> json) {
    return FlatModel(
      id: json['id'] ?? 0,
      flatNumber: json['flatNumber']?.toString() ?? "",
      flatFloor: json['flatFloor']?.toString() ?? "",
      name: json['nameAr'].toString() ?? "",
      bedsNumber: json['bedsNumber']?.toString() ?? "0",
      balconiesNumber: json['balconiesNumber']?.toString() ?? "",
      bathroomsNumber: json['bathroomsNumber']?.toString() ?? "0",
      price_per_night: (json['price_per_night'] as num?)?.toDouble(),
      weekend_price_per_night: (json['weekend_price_per_night'] as num?)?.toDouble(), // API capitalization typo matched
      flatType: json['flattype'] ?? 0, // API typo matched
      rentPriceDescription: json['rentPriceDescrption'], // API typo matched
      note: json['note'],
      insuranceamount: json['insurance_amount'] ?? 0.0,
      hotelBuildingId: json['hotelbuildingID'] ?? 0, // API capitalization matched
      image: json['coverimg'] ?? "",
      typeId: json['typeId'] ?? 0,
      managmentPhone: "",
      todayOfferEnabled: json['todayOfferEnabled'] as bool? ?? false,
      todayOfferPercent: (json['todayOfferPercent'] as num?)?.toInt() ?? 0,
      todayOfferTriggerHour:
          (json['todayOfferTriggerHour'] as num?)?.toInt() ?? 12,
      todayOfferActive: json['todayOfferActive'] as bool? ?? false,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flatNumber': flatNumber,
      'flatFloor': flatFloor,
      'bedsNumber': bedsNumber,
      'balconiesNumber': balconiesNumber,
      'bathroomsNumber': bathroomsNumber,
      'price_per_night': price_per_night,
      'weekend_price_per_night': weekend_price_per_night,
      'flattype': flatType,
      'rentPriceDescrption': rentPriceDescription,
      'note': note,
      'hotelbuildingID': hotelBuildingId,
      'image': image,
      'todayOfferEnabled': todayOfferEnabled,
      'todayOfferPercent': todayOfferPercent,
      'todayOfferTriggerHour': todayOfferTriggerHour,
      'todayOfferActive': todayOfferActive,
    };
  }
}