import '../../domain/entities/building_details_model.dart';

class BuildingDetailsModel extends BuildingDetails {
  final String nameAr;
  final String nameEn;
  final int totalFloor;
  final int totalFlats;
  final String yearBuilt;
  final String minimumRent;
  final String maxRent;
  final int minDays;
  final String buldingDescriptionAr;
  final String buldingDescriptionEn;
  final String additionalDetailsAr;
  final String additionalDetailsEn;
  final String location;
  final String managementPhone;
  final String workerPhone;
  final String buildingPolicyAr;
  final String buildingPolicyEn;
  final String cancelationPolicyAr;
  final String cancelationPolicyEn;
  final String buildingNumber;
  final String coverImg;
  final String nearTo;
  final bool onlinePay;
  final bool acceptDownPay;
  final String checkIn;
  final String checkOut;
  final bool isExclusive;
  final bool isDeleted;
  final int buildStatus;
  final List<dynamic> buildingFlatType;
  final List<dynamic> buildingPaymentMethods;
  final int ownerId;

  // ── Today's Offer — owner-controlled, last-minute, day-of-only discount.
  // Set once per building — see Building entity (list endpoint) for the
  // fuller explanation.
  final bool todayOfferEnabled;
  final int todayOfferPercent;
  final int todayOfferTriggerHour;
  final bool todayOfferActive;

  BuildingDetailsModel({
    required int id,
    required this.nameAr,
    required this.nameEn,
    required this.totalFloor,
    required this.totalFlats,
    required this.yearBuilt,
    required this.minimumRent,
    required this.maxRent,
    required this.minDays,
    required this.buldingDescriptionAr,
    required this.buldingDescriptionEn,
    required this.additionalDetailsAr,
    required this.additionalDetailsEn,
    required String state,
    required String gouvernate,
    required this.location,
    required String lat,
    required String lng,
    required this.managementPhone,
    required this.workerPhone,
    required this.buildingPolicyAr,
    required this.buildingPolicyEn,
    required this.cancelationPolicyAr,
    required this.cancelationPolicyEn,
    required this.buildingNumber,
    required this.coverImg,
    required this.nearTo,
    required this.onlinePay,
    required this.acceptDownPay,
    required this.checkIn,
    required this.checkOut,
    required this.isExclusive,
    required bool isActive,
    required this.isDeleted,
    required bool stopBook,
    required this.buildStatus,
    required List<Map<String, dynamic>> buldingImages,
    required this.buildingFlatType,
    required this.buildingPaymentMethods,
    required List<Map<String, dynamic>> buldingService,
    required this.ownerId,
    this.todayOfferEnabled = false,
    this.todayOfferPercent = 0,
    this.todayOfferTriggerHour = 12,
    this.todayOfferActive = false,
  }) : super(
    id: id,
    // Mapping name defaults to English fallback if empty
    name: nameEn.isNotEmpty ? nameEn : nameAr,
    buldingDescrption: buldingDescriptionEn.isNotEmpty ? buldingDescriptionEn : buldingDescriptionAr,
    state: state,
    gouvernate: gouvernate,
    lat: lat,
    lng: lng,
    isActive: isActive,
    stopBook: stopBook,
    buldingImages: buldingImages,
    buldingService: buldingService,
  );

  factory BuildingDetailsModel.fromJson(Map<String, dynamic> json) {
    return BuildingDetailsModel(
      id: json['id'] ?? 0,
      nameAr: json['nameAr'] ?? "",
      nameEn: json['nameEn'] ?? "",
      totalFloor: json['totalFloor'] ?? 0,
      totalFlats: json['totalFlats'] ?? 0,
      yearBuilt: json['yearBulit']?.toString() ?? "", // Handles safe cast if int
      minimumRent: json['minimumRent'] ?? "",
      maxRent: json['maxRent'] ?? "",
      minDays: json['minDays'] ?? 0,
      buldingDescriptionAr: json['buldingDescrptionAr'] ?? "",
      buldingDescriptionEn: json['buldingDescrptionEn'] ?? "",
      additionalDetailsAr: json['additional_detailsAr'] ?? "",
      additionalDetailsEn: json['additional_detailsEn'] ?? "",
      gouvernate: json['gouvernate'] ?? "",
      state: json['state'] ?? "",
      location: json['location'] ?? "",
      lat: json['lat'] ?? "",
      lng: json['lng'] ?? "",
      managementPhone: json['managmentPhone'] ?? "",
      workerPhone: json['workerPhone'] ?? "",
      buildingPolicyAr: json['buildingPolicyAr'] ?? "",
      buildingPolicyEn: json['buildingPolicyEn'] ?? "",
      cancelationPolicyAr: json['cancelation_policyAr'] ?? "",
      cancelationPolicyEn: json['cancelation_policyEn'] ?? "",
      buildingNumber: json['buldinNumber'] ?? "",
      coverImg: json['coverimg'] ?? "",
      nearTo: json['nearTo'] ?? "",
      onlinePay: json['onlinePay'] ?? false,
      acceptDownPay: json['acceptDownPay'] ?? false,
      checkIn: json['check_In'] ?? "",
      checkOut: json['check_Out'] ?? "",
      isExclusive: json['isExclusive'] ?? false,
      isActive: json['isActive'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      stopBook: json['stopBook'] ?? false,
      buildStatus: json['bulidstatus'] ?? 0,
      buldingImages: json['buldingImages'] != null
          ? List<Map<String, dynamic>>.from(json['buldingImages'])
          : [],
      buildingFlatType: json['buildingFlatType'] != null
          ? List<dynamic>.from(json['buildingFlatType'])
          : [],
      buildingPaymentMethods: json['buildingPayment_methods'] != null
          ? List<dynamic>.from(json['buildingPayment_methods'])
          : [],
      buldingService: json['buldingService'] != null
          ? List<Map<String, dynamic>>.from(json['buldingService'])
          : [],
      ownerId: json['ownerId'] ?? 0,
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
      'totalFloor': totalFloor,
      'totalFlats': totalFlats,
      'yearBulit': yearBuilt,
      'minimumRent': minimumRent,
      'maxRent': maxRent,
      'minDays': minDays,
      'buldingDescrptionAr': buldingDescriptionAr,
      'buldingDescrptionEn': buldingDescriptionEn,
      'additional_detailsAr': additionalDetailsAr,
      'additional_detailsEn': additionalDetailsEn,
      'gouvernate': gouvernate,
      'state': state,
      'location': location,
      'lat': lat,
      'lng': lng,
      'managmentPhone': managementPhone,
      'workerPhone': workerPhone,
      'buildingPolicyAr': buildingPolicyAr,
      'buildingPolicyEn': buildingPolicyEn,
      'cancelation_policyAr': cancelationPolicyAr,
      'cancelation_policyEn': cancelationPolicyEn,
      'buldinNumber': buildingNumber,
      'coverimg': coverImg,
      'nearTo': nearTo,
      'onlinePay': onlinePay,
      'acceptDownPay': acceptDownPay,
      'check_In': checkIn,
      'check_Out': checkOut,
      'isExclusive': isExclusive,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'stopBook': stopBook,
      'bulidstatus': buildStatus,
      'buldingImages': buldingImages,
      'buildingFlatType': buildingFlatType,
      'buildingPayment_methods': buildingPaymentMethods,
      'buldingService': buldingService,
      'ownerId': ownerId,
      'todayOfferEnabled': todayOfferEnabled,
      'todayOfferPercent': todayOfferPercent,
      'todayOfferTriggerHour': todayOfferTriggerHour,
      'todayOfferActive': todayOfferActive,
    };
  }
}