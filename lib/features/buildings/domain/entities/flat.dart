import 'package:equatable/equatable.dart';

class Flat extends Equatable {
  final int id;
  final String flatNumber;
  final String nameAr;
   String managmentPhone ;


  final String flatFloor;
  final String bedsNumber;
  final String balconiesNumber;
  final String bathroomsNumber;
  final double? price_per_night;
  final double? weekend_price_per_night;
  final int flatType;
  final String? rentPriceDescription;
  final String? note;
  final int hotelBuildingId;
  final String coverimg;
   int? minDays ;

  // ── Today's Offer — owner-controlled, last-minute, day-of-only discount.
  // Same fields/meaning as on Chalet — see that entity for the fuller
  // explanation.
  final bool todayOfferEnabled;
  final int todayOfferPercent;
  final int todayOfferTriggerHour;
  final bool todayOfferActive;

   Flat({
    required this.id,
    required this.nameAr,
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
    required this.coverimg, required this.minDays,
     required this.managmentPhone,
     this.todayOfferEnabled = false,
     this.todayOfferPercent = 0,
     this.todayOfferTriggerHour = 12,
     this.todayOfferActive = false,
  });

  @override
  List<Object?> get props => [
    id,
    nameAr,
    flatNumber,

    flatFloor,
    bedsNumber,
    balconiesNumber,
    bathroomsNumber,
    price_per_night,
    weekend_price_per_night,
    flatType,
    rentPriceDescription,
    note,
    hotelBuildingId,
    coverimg,
    todayOfferEnabled,
    todayOfferPercent,
    todayOfferTriggerHour,
    todayOfferActive,
  ];
}