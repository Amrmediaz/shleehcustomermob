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
      required super.fullDayDiscountEnabledText});

  factory ChaletModel.fromJson(Map<String, dynamic> json) {
    return ChaletModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      rentFullday: json['rentFullday'] ?? "",
      rentFullDayDiscount: json['rentFulldayDisCount'] ?? "",
      rentHalfDay: json['rentHalfday'] ?? "",
      rentHalfDayDiscount: json['rentHalfdayDisCount'] ?? "",
      buildingDescription: json['buldingDescrption'] ?? "",
      state: json['state'] ?? "",
      governorate: json['gouvernate'] ?? "",
      image: json['image'] ?? "",
      rateAverage: json['rateAverage'] ?? "",
      breakfastEnabled: json['breakfastenabled'] ?? "",
      fullDayDiscountEnabled: json['fulldayDiscountenabled']  ?? "",
      fullDayDiscountEnabledText: json['fulldayDiscountenabledText'] ?? "",
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
    };
  }
}
