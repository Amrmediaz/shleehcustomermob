import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

class Chalet extends Equatable {
  final int id;
  final String name;
  final String rentFullday;
  final String rentFullDayDiscount;
  final String rentHalfDay;
  final String rentHalfDayDiscount;
  final String buildingDescription;
  final String state;
  final String governorate;
  final String image;
  final dynamic rateAverage;
  final bool breakfastEnabled;
  final bool fullDayDiscountEnabled;
  final dynamic fullDayDiscountEnabledText;

  // ── New structured fields — list endpoint only ─────────────────────
  // Confirmed: the /list response only ever sends these 4 of the 12 new
  // fields (chaletType, capacity, bedrooms, landscape) — bathrooms,
  // livingRooms, suitableFor, outdoorSpace, safety, atmosphere,
  // bestSeason and area are NOT part of this endpoint's payload at all
  // (that's a detail-endpoint-only thing, see ChaletDetails). Nullable
  // because older records predate even these 4. Not modeling the other
  // 8 here since they'd always be null/undefined noise on this class.
  final String? chaletType;
  final String? capacity;
  final String? bedrooms;
  final String? landscape;

  // Whether the owner has locked bookings for this chalet. Nullable/
  // optional for the same reason as the fields above — treat null as
  // "unknown/not locked" rather than crashing on older payloads.
  final bool? stopBook;

  // Minimum nights required per booking. Parsed but never surfaced in the
  // UI before — nullable since older payloads may not send it; treat
  // null/0/1 as "nothing worth telling the user" (every booking is at
  // least 1 night anyway).
  final int? minDays;

  // ── Today's Offer — owner-controlled, last-minute, day-of-only discount.
  // Separate from fullDayDiscountEnabled (a permanent full-day/half-day
  // rental discount) and from special/date-specific prices. `todayOfferActive`
  // is the only field that actually matters for display: it's true only when
  // the offer is enabled AND today specifically qualifies (no booking
  // blocking it), computed server-side. All nullable/defaulted since most
  // chalets never set this up.
  final bool todayOfferEnabled;
  final int todayOfferPercent;
  final int todayOfferTriggerHour;
  final bool todayOfferActive;

  const Chalet({
    required this.id,
    required this.name,
    required this.rentFullday,
    required this.rentFullDayDiscount,
    required this.rentHalfDay,
    required this.rentHalfDayDiscount,
    required this.buildingDescription,
    required this.state,
    required this.governorate,
    required this.image,
    required this.rateAverage,
    required this.breakfastEnabled,
    required this.fullDayDiscountEnabled,
    required this.fullDayDiscountEnabledText,
    this.chaletType,
    this.capacity,
    this.bedrooms,
    this.landscape,
    this.stopBook,
    this.minDays,
    this.todayOfferEnabled = false,
    this.todayOfferPercent = 0,
    this.todayOfferTriggerHour = 12,
    this.todayOfferActive = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    rentFullday,
    rentFullDayDiscount,
    rentHalfDay,
    rentHalfDayDiscount,
    buildingDescription,
    state,
    governorate,
    image,
    rateAverage,
    breakfastEnabled,
    fullDayDiscountEnabled,
    fullDayDiscountEnabledText,
    chaletType,
    capacity,
    bedrooms,
    landscape,
    stopBook,
    minDays,
    todayOfferEnabled,
    todayOfferPercent,
    todayOfferTriggerHour,
    todayOfferActive,
  ];
}