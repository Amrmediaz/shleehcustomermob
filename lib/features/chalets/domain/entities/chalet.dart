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
  ];
}
