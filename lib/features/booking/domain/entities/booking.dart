import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String state;
  final String governorate;
  final dynamic coast;
  final int noOfDays;
  final String? note;
  final String createdDate;
  final int bookingStatus;
  final List<String> bookingDays;
  final int buildingID;
  final int customerId;

  const Booking({
    required this.id,
    required this.name,
    required this.phone,
    required this.state,
    required this.governorate,
    required this.coast,
    required this.noOfDays,
    this.note,
    required this.createdDate,
    required this.bookingStatus,
    required this.bookingDays,
    required this.buildingID,
    required this.customerId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    state,
    governorate,
    coast,
    noOfDays,
    note,
    createdDate,
    bookingStatus,
    bookingDays,
    buildingID,
    customerId,
  ];
}
