import '../../data/models/chalet_details.dart';


class ChaletDetails {
    int id;
    String name;
    String rentFullday;
    String rentFulldayDisCount;
    String rentHalfday;
    String rentHalfdayDisCount;
    String buldingDescrption;
    String note;
    String state;
    String gouvernate;
    String lat;
    String lng;
    int minDays;
    bool showComments;
    bool isActive;
    bool stopBook;
    String offDayPriceFullday;
    String offDayPriceHalfday;
    String crreatedDate;
    String rentweekend;
    bool acceptDeposit;
    bool breakfastenabled;
    bool fulldayDiscountenabled;
    String fulldayDiscountenabledText;
    String insuranceamount;
    int rateAverage;
    List<Map<String,  dynamic>> buldingImages;
    List<Map<String, dynamic>> buldingService;
    List<dynamic> discountfullDate;
    List<dynamic> discountHalfDate;
    List<Map<String, dynamic>> buldingComment;
    int apartmentOwnerId;

    // ── New structured fields (new API body) ──────────────────────────
    // Nullable: chalets saved before these fields existed will come back
    // with them null, so anything reading these should fall back to
    // parsing buldingDescrption the same way the owner app does.
    String? chaletType;
    String? capacity;
    String? bedrooms;
    String? bathrooms;
    String? livingRooms;
    String? suitableFor;
    String? landscape;
    String? outdoorSpace;
    String? safety;
    String? atmosphere;
    String? bestSeason;
    String? area;

    // ── Today's Offer — owner-controlled, last-minute, day-of-only
    // discount. See Chalet entity (list endpoint) for the fuller
    // explanation; same fields, same meaning, just on the details payload.
    bool todayOfferEnabled;
    int todayOfferPercent;
    int todayOfferTriggerHour;
    bool todayOfferActive;

    ChaletDetails({
        required this.id,
        required this.name,
        required this.rentFullday,
        required this.rentFulldayDisCount,
        required this.rentHalfday,
        required this.rentHalfdayDisCount,
        required this.buldingDescrption,
        required this.note,
        required this.state,
        required this.gouvernate,
        required this.lat,
        required this.lng,
        required this.showComments,
        required this.isActive,
        required this.stopBook,
        required this.offDayPriceFullday,
        required this.offDayPriceHalfday,
        required this.crreatedDate,
        required this.minDays,
        required this.rentweekend,
        required this.acceptDeposit,
        required this.breakfastenabled,
        required this.fulldayDiscountenabled,
        required this.fulldayDiscountenabledText,
        required this.insuranceamount,
        required this.rateAverage,
        required this.buldingImages,
        required this.buldingService,
        required this.discountfullDate,
        required this.discountHalfDate,
        required this.buldingComment,
        required this.apartmentOwnerId,
        this.chaletType,
        this.capacity,
        this.bedrooms,
        this.bathrooms,
        this.livingRooms,
        this.suitableFor,
        this.landscape,
        this.outdoorSpace,
        this.safety,
        this.atmosphere,
        this.bestSeason,
        this.area,
        this.todayOfferEnabled = false,
        this.todayOfferPercent = 0,
        this.todayOfferTriggerHour = 12,
        this.todayOfferActive = false,
    });

    factory ChaletDetails.fromJson(Map<String, dynamic> json) {
        return ChaletDetails(
            id: json['id'],
            name: json['name'],
            rentFullday: json['rentFullday'],
            rentFulldayDisCount: json['rentFulldayDisCount'],
            rentHalfday: json['rentHalfday'],
            rentHalfdayDisCount: json['rentHalfdayDisCount'],
            buldingDescrption: json['buldingDescrption'],
            note: json['note'],
            state: json['state'],
            gouvernate: json['gouvernate'],
            lat: json['lat'],
            lng: json['lng'],
            showComments: json['showComments'],
            isActive: json['isActive'],
            stopBook: json['stopBook'],
            offDayPriceFullday: json['offDayPriceFullday'],
            offDayPriceHalfday: json['offDayPriceHalfday'],
            crreatedDate: json['crreatedDate'],
            rentweekend: json['rentweekend'],
            acceptDeposit: json['acceptDeposit'],
            breakfastenabled: json['breakfastenabled'],
            fulldayDiscountenabled: json['fulldayDiscountenabled'],
            fulldayDiscountenabledText: json['fulldayDiscountenabledText'],
            insuranceamount: json['insuranceamount'],
            minDays: json["minDays"],
            rateAverage: json['rateAverage'],
            buldingImages: List<Map<String, String>>.from(json['buldingImages']),
            buldingService: List<Map<String, dynamic>>.from(json['buldingService']),
            discountfullDate: List<dynamic>.from(json['discountfullDate']),
            discountHalfDate: List<dynamic>.from(json['discountHalfDate']),
            buldingComment: List<Map<String, dynamic>>.from(json['buldingComment']),
            apartmentOwnerId: json['apartmentOwnerId'],

            // New structured fields — read defensively since older records
            // won't have them at all (null is the expected/handled case, not
            // an error).
            chaletType: json['chaletType'] as String?,
            capacity: json['capacity']?.toString(),
            bedrooms: json['bedrooms']?.toString(),
            bathrooms: json['bathrooms']?.toString(),
            livingRooms: json['livingRooms']?.toString(),
            suitableFor: json['suitableFor'] as String?,
            landscape: json['landscape'] as String?,
            outdoorSpace: json['outdoorSpace'] as String?,
            safety: json['safety'] as String?,
            atmosphere: json['atmosphere'] as String?,
            bestSeason: json['bestSeason'] as String?,
            area: json['area']?.toString(),
            todayOfferEnabled: json['todayOfferEnabled'] as bool? ?? false,
            todayOfferPercent: (json['todayOfferPercent'] as num?)?.toInt() ?? 0,
            todayOfferTriggerHour:
                (json['todayOfferTriggerHour'] as num?)?.toInt() ?? 12,
            todayOfferActive: json['todayOfferActive'] as bool? ?? false,
        );
    }

}