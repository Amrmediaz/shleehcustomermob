import 'package:shleehcustomer/features/chalets/domain/entities/chalet_map.dart';

import '../../domain/entities/chalet.dart';

class ChaletMapModel extends ChaletMap {
  ChaletMapModel({required super.id,
    required super.name,
    required super.lat,
    required super.lng,
  });

  factory ChaletMapModel.fromJson(Map<String, dynamic> json) {
    return ChaletMapModel(
      id: json['id'],
      name: json['name'],
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
