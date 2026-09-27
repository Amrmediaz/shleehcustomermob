import 'electronic_device_translations.dart';

/// Model for a single image entry inside the flat-details API response.
class FlatImageModel {
  final int id;
  final String path;
  final int flatId;

  const FlatImageModel({required this.id, required this.path, required this.flatId});

  factory FlatImageModel.fromJson(Map<String, dynamic> json) {
    return FlatImageModel(
      id: json['id'] ?? 0,
      path: json['path'] ?? '',
      flatId: json['flatID'] ?? 0,
    );
  }
}

/// Model for a single electronic device/amenity entry.
class ElectronicDeviceModel {
  final int id;
  final String serviceName;
  final int flatId;

  const ElectronicDeviceModel({
    required this.id,
    required this.serviceName,
    required this.flatId,
  });

  /// Arabic display label for [serviceName] (falls back to the raw API
  /// value if no translation is available).
  String get serviceNameAr => ElectronicDeviceTranslations.translate(serviceName);

  factory ElectronicDeviceModel.fromJson(Map<String, dynamic> json) {
    return ElectronicDeviceModel(
      id: json['id'] ?? 0,
      serviceName: json['serviceName'] ?? '',
      flatId: json['flatID'] ?? 0,
    );
  }
}

/// Full flat-details model, parsed from
/// GET https://shleeh.com/api/FlatsCustomer/GetFlatData?FlatId={id}
class FlatDetailsModel {
  final int id;
  final String flatNumber;
  final String flatFloor;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String additionalDetailsAr;
  final String additionalDetailsEn;
  final int visitorsCount;
  final int typeId;
  final int count;
  final int occupied;
  final String bedsNumber;
  final String balconiesNumber;
  final String bathroomsNumber;
  final double pricePerNight;
  final double weekendPricePerNight;
  final double insuranceAmount;
  final String coverImg;
  final bool showComments;
  final bool isActive;
  final bool stopBook;
  final List<FlatImageModel> flatImages;
  final List<ElectronicDeviceModel> electronicDevices;
  final int hotelBuildingId;

  const FlatDetailsModel({
    required this.id,
    required this.flatNumber,
    required this.flatFloor,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.additionalDetailsAr,
    required this.additionalDetailsEn,
    required this.visitorsCount,
    required this.typeId,
    required this.count,
    required this.occupied,
    required this.bedsNumber,
    required this.balconiesNumber,
    required this.bathroomsNumber,
    required this.pricePerNight,
    required this.weekendPricePerNight,
    required this.insuranceAmount,
    required this.coverImg,
    required this.showComments,
    required this.isActive,
    required this.stopBook,
    required this.flatImages,
    required this.electronicDevices,
    required this.hotelBuildingId,
  });

  /// Convenience: prefers the Arabic name, falls back to English.
  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;

  /// Convenience: prefers the Arabic description, falls back to English.
  String get displayDescription => descriptionAr.isNotEmpty ? descriptionAr : descriptionEn;

  /// Convenience: prefers the Arabic extra details, falls back to English.
  String get displayAdditionalDetails =>
      additionalDetailsAr.isNotEmpty ? additionalDetailsAr : additionalDetailsEn;

  /// All gallery images, cover image first (deduplicated).
  List<String> get galleryImageUrls {
    final urls = <String>[];
    if (coverImg.isNotEmpty) urls.add(coverImg);
    for (final img in flatImages) {
      if (img.path.isNotEmpty && !urls.contains(img.path)) urls.add(img.path);
    }
    return urls;
  }

  factory FlatDetailsModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    return FlatDetailsModel(
      id: json['id'] ?? 0,
      flatNumber: json['flatNumber'] ?? '',
      flatFloor: json['flatFloor'] ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      descriptionAr: json['descrptionAr'] ?? '',
      descriptionEn: json['descrptionEn'] ?? '',
      additionalDetailsAr: json['additional_detailsAr'] ?? '',
      additionalDetailsEn: json['additional_detailsEn'] ?? '',
      visitorsCount: int.tryParse('${json['visitors_count'] ?? 0}') ?? 0,
      typeId: json['typeId'] ?? 0,
      count: json['count'] ?? 0,
      occupied: json['occupied'] ?? 0,
      bedsNumber: '${json['bedsNumber'] ?? ''}',
      balconiesNumber: '${json['balconiesNumber'] ?? ''}',
      bathroomsNumber: '${json['bathroomsNumber'] ?? ''}',
      pricePerNight: _toDouble(json['price_per_night']),
      weekendPricePerNight: _toDouble(json['weekend_price_per_night']),
      insuranceAmount: _toDouble(json['insurance_amount']),
      coverImg: json['coverimg'] ?? '',
      showComments: json['showComments'] ?? false,
      isActive: json['isActive'] ?? false,
      stopBook: json['stopBook'] ?? false,
      flatImages: ((json['flatImages'] as List?) ?? [])
          .map((e) => FlatImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      electronicDevices: ((json['electronic_devices'] as List?) ?? [])
          .map((e) => ElectronicDeviceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hotelBuildingId: json['hotelbuildingID'] ?? 0,
    );
  }
}