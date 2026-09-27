import 'package:shleehcustomer/features/buildings/domain/entities/building_map.dart';

import '../../domain/entities/Building.dart';

class BuildingMapModel extends BuildingMap {
  BuildingMapModel({required super.id,
    required super.name,
    required super.lat,
    required super.lng,
  });

  factory BuildingMapModel.fromJson(Map<String, dynamic> json) {
    return BuildingMapModel(
      id: json['id'],
      name: json['name'] ?? "",
      lat: json['lat'],
      lng: json['lng'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
  };
}}
