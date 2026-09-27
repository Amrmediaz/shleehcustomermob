import 'package:flutter/material.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building_details_model.dart';

import '../../../../../../core/strings/language.dart';
import '../../../../../../core/widgets/today_offer_widgets.dart';
import '../../../../data/models/building_details.dart';

class PriceCardWidget extends StatelessWidget {
  final BuildingDetailsModel building;
  final Color primaryColor;

  const PriceCardWidget({
    Key? key,
    required this.building,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minRent = building.minimumRent ?? '0';
    final maxRent = building.maxRent ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (building.todayOfferActive) ...[
          TodayOfferBanner(
            percent: building.todayOfferPercent,
            subtitle: 'الخصم يسري على أول ليلة عند الحجز اليوم',
          ),
          const SizedBox(height: 12),
        ],
        _buildPriceBox(minRent: minRent.toString(), maxRent: maxRent),
      ],
    );
  }

  Widget _buildPriceBox({required String minRent, required String maxRent}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.15), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTextByKey(key: TranslationKey.keyPrice),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceColumn(
                label: getTextByKey(key: TranslationKey.keyBestPriceStartingFrom),
                price: minRent,
                primaryColor: primaryColor,
              ),
              Container(
                width: 0.8,
                height: 45,
                color: primaryColor.withOpacity(0.2),
              ),
              _buildPriceColumn(
                label: getTextByKey(key: TranslationKey.keyMaximum),
                price: maxRent,
                primaryColor: primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceColumn({
    required String label,
    required String price,
    required Color primaryColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                getTextByKey(key: TranslationKey.keyOMR),
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}