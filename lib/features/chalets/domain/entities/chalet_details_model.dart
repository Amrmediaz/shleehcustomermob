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
    rateAverage: json['rateAverage'],
    buldingImages: List<Map<String, String>>.from(json['buldingImages']),
    buldingService: List<Map<String, dynamic>>.from(json['buldingService']),
    discountfullDate: List<dynamic>.from(json['discountfullDate']),
    discountHalfDate: List<dynamic>.from(json['discountHalfDate']),
    buldingComment: List<Map<String, dynamic>>.from(json['buldingComment']),
    apartmentOwnerId: json['apartmentOwnerId'],
    );
    }

}