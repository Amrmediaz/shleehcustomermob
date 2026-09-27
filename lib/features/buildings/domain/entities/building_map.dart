import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

class BuildingMap extends Equatable {
  final int id;
  final String name;
  final String lat;
  final String lng;


  const BuildingMap({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,

  });

  @override
  List<Object?> get props => [
    id,
    name,
    lat,
    lng,

  ];
}
