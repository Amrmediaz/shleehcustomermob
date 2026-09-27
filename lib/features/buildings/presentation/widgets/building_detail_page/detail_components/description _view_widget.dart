import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building_details_model.dart';

import '../../../../../../core/strings/language.dart';
import '../../../../data/models/building_details.dart';

class DescriptionViewWidget extends StatelessWidget {
  final BuildingDetailsModel building;
  final Color primaryColor;

  const DescriptionViewWidget({
    Key? key,
    required this.building,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final description = building.buldingDescrption ?? 'No description available';
    final services = building.buldingService ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        Text(
          description.isEmpty ? getTextByKey(key: TranslationKey.keyNoDescriptionAvailable) : description,
          style: TextStyle(
            color: Colors.grey[700],
            height: 1.6,
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
          ),
        ),
        const SizedBox(height: 28),

        // Services Section
        Row(
          children: [
            Icon(Icons.checkroom_outlined, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              getTextByKey(key: TranslationKey.keyAvailableServices),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Services List
        if (services.isNotEmpty)
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: List.generate(
              services.length,
                  (index) {
                final service = services[index];
                final serviceName = servicesEnglishToArabicBuilding[ service['serviceName'].toString().toLowerCase()] ?? '';
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 250 + (index * 40)),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _buildServiceChip(serviceName, primaryColor),
                );
              },
            ),
          )
        else
          Text(
            getTextByKey(key: TranslationKey.keyNoServicesAvailable),
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
      ],
    );
  }

  Widget _buildServiceChip(String serviceName, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: primaryColor.withOpacity(0.15),
          width: 0.8,
        ),
      ),
      child: Text(
        serviceName.trim(),
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}