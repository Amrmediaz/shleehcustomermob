import '../../domain/entities/chalet.dart';

class ChaletModel extends Chalet {
  ChaletModel(
      {required super.id,
        required super.name,
        required super.rentFullday,
        required super.rentFullDayDiscount,
        required super.rentHalfDay,
        required super.rentHalfDayDiscount,
        required super.buildingDescription,
        required super.state,
        required super.governorate,
        required super.image,
        required super.rateAverage,
        required super.breakfastEnabled,
        required super.fullDayDiscountEnabled,
        required super.fullDayDiscountEnabledText,
        // New structured fields (new API body) — optional/nullable since
        // the list endpoint only sends these 4 out of the full set, and
        // older records predate them entirely.
        super.chaletType,
        super.capacity,
        super.bedrooms,
        super.landscape,
        super.stopBook,
        super.minDays,
        super.todayOfferEnabled,
        super.todayOfferPercent,
        super.todayOfferTriggerHour,
        super.todayOfferActive});

  factory ChaletModel.fromJson(Map<String, dynamic> json) {
    return ChaletModel(
      id: json['id'],
      name: json['name'],
      rentFullday: json['rentFullday'],
      rentFullDayDiscount: json['rentFulldayDisCount'] ?? "",
      rentHalfDay: json['rentHalfday'],
      rentHalfDayDiscount: json['rentHalfdayDisCount'] ?? "",
      buildingDescription: json['buldingDescrption'],
      state: json['state'],
      governorate: json['gouvernate'],
      image: json['image'] ?? "",
      rateAverage: json['rateAverage'],
      breakfastEnabled: json['breakfastenabled'],
      fullDayDiscountEnabled: json['fulldayDiscountenabled'],
      fullDayDiscountEnabledText: json['fulldayDiscountenabledText'],
      // Read defensively — null/absent is the expected case for older
      // chalets or any endpoint that doesn't include them.
      chaletType: json['chaletType'] as String?,
      capacity: json['capacity']?.toString(),
      bedrooms: json['bedrooms']?.toString(),
      landscape: json['landscape'] as String?,
      stopBook: json['stopBook'] as bool?,
      minDays: (json['minDays'] as num?)?.toInt(),
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
      'name': name,
      'rentFullday': rentFullday,
      'rentFulldayDisCount': rentFullDayDiscount,
      'rentHalfday': rentHalfDay,
      'rentHalfdayDisCount': rentHalfDayDiscount,
      'buldingDescrption': buildingDescription,
      'state': state,
      'gouvernate': governorate,
      'image': image,
      'rateAverage': rateAverage,
      'breakfastenabled': breakfastEnabled,
      'fulldayDiscountenabled': fullDayDiscountEnabled,
      'fulldayDiscountenabledText': fullDayDiscountEnabledText,
      if (chaletType != null) 'chaletType': chaletType,
      if (capacity != null) 'capacity': capacity,
      if (bedrooms != null) 'bedrooms': bedrooms,
      if (landscape != null) 'landscape': landscape,
      if (stopBook != null) 'stopBook': stopBook,
      if (minDays != null) 'minDays': minDays,
      'todayOfferEnabled': todayOfferEnabled,
      'todayOfferPercent': todayOfferPercent,
      'todayOfferTriggerHour': todayOfferTriggerHour,
      'todayOfferActive': todayOfferActive,
    };
  }
}