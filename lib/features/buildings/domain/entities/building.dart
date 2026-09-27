import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

class Building extends Equatable {
  final int id;
  final String name;
  final String minimumRent;
  final String maxRent;
  final String buildingDescription;
  final String state;
  final String governorate;
  final String image;
  final bool isExclusive;

  // ── Today's Offer — owner-controlled, last-minute, day-of-only discount.
  // Set once per building (not per flat) and applies to whichever flat the
  // guest ends up booking — see the owner app's BuildingTodayOfferTab for
  // the source of truth on this design.
  final bool todayOfferEnabled;
  final int todayOfferPercent;
  final int todayOfferTriggerHour;
  final bool todayOfferActive;

  const Building({
    required this.id,
    required this.name,
    required this.minimumRent,
    required this.maxRent,
    required this.buildingDescription,
    required this.state,
    required this.governorate,
    required this.image,
    required this.isExclusive,
    this.todayOfferEnabled = false,
    this.todayOfferPercent = 0,
    this.todayOfferTriggerHour = 12,
    this.todayOfferActive = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    minimumRent,
    maxRent,
    buildingDescription,
    state,
    governorate,
    image,
    isExclusive,
    todayOfferEnabled,
    todayOfferPercent,
    todayOfferTriggerHour,
    todayOfferActive,
  ];
}