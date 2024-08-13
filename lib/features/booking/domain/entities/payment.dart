import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

import '../../../chalets/domain/entities/chalet_details_model.dart';

class PaymentDetails extends Equatable {
  final double totalCost;
  final int daysCount;
  final String daysRange;
  final String insurance;
  final bool arbon;
  final int bookingId;
  final double currentPaid;

  final ChaletDetails chalet;
  final List<Map<String, dynamic>> bookingDaysCalculatePrice ;


  const PaymentDetails({
    required this.totalCost,
    required this.daysCount,
    required this.daysRange,
    required this.insurance,
    required this.bookingId,
    required this.arbon ,
    required this.currentPaid,
    required this.chalet,
    required this.bookingDaysCalculatePrice

  });

  @override
  List<Object?> get props => [

  ];
}
