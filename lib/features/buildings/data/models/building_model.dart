import '../../domain/entities/building.dart';

import '../../domain/entities/building.dart';

class BuildingModel extends Building {
  final String nameAr;
  final String nameEn;
  final String minimumRent;
  final String maxRent;
  final String buildingDescriptionAr;
  final String buildingDescriptionEn;
  final String coverImg;
  final bool isExclusive;

   BuildingModel({
    required int id,
    required this.nameAr,
    required this.nameEn,
    required this.minimumRent,
    required this.maxRent,
    required this.buildingDescriptionAr,
    required this.buildingDescriptionEn,
    required String state,
    required String governorate,
    required this.coverImg,
    required this.isExclusive,
    bool todayOfferEnabled = false,
    int todayOfferPercent = 0,
    int todayOfferTriggerHour = 12,
    bool todayOfferActive = false,
  }) : super(
    id: id,
    name: nameEn.isNotEmpty ? nameEn : nameAr,
    minimumRent: minimumRent,
    maxRent: maxRent,
    buildingDescription: buildingDescriptionEn.isNotEmpty ? buildingDescriptionEn : buildingDescriptionAr,
    state: state,
    governorate: governorate,
    image: coverImg,
    isExclusive: isExclusive,
    todayOfferEnabled: todayOfferEnabled,
    todayOfferPercent: todayOfferPercent,
    todayOfferTriggerHour: todayOfferTriggerHour,
    todayOfferActive: todayOfferActive,
  );

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    return BuildingModel(
      id: json['id'] ?? 0,
      nameAr: json['nameAr'] ?? "",
      nameEn: json['nameEn'] ?? "",
      minimumRent: json['minimumRent'] ?? "",
      maxRent: json['maxRent'] ?? "",
      buildingDescriptionAr: json['buldingDescrptionAr'] ?? "",
      buildingDescriptionEn: json['buldingDescrptionEn'] ?? "",
      state: json['state'] ?? "",
      governorate: json['gouvernate'] ?? "",
      coverImg: json['coverimg'] ?? "",
      isExclusive: json['isExclusive'] ?? false,
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
      'nameAr': nameAr,
      'nameEn': nameEn,
      'minimumRent': minimumRent,
      'maxRent': maxRent,
      'buldingDescrptionAr': buildingDescriptionAr,
      'buldingDescrptionEn': buildingDescriptionEn,
      'state': state,
      'gouvernate': governorate,
      'coverimg': coverImg,
      'isExclusive': isExclusive,
      'todayOfferEnabled': todayOfferEnabled,
      'todayOfferPercent': todayOfferPercent,
      'todayOfferTriggerHour': todayOfferTriggerHour,
      'todayOfferActive': todayOfferActive,
    };
  }
}