import 'package:flutter/material.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building_details_model.dart';

import '../../../../../../core/strings/language.dart';
import '../../../../data/models/building_details.dart';

class PoliciesViewWidget extends StatelessWidget {
  final BuildingDetailsModel building;
  final Color primaryColor;

  const PoliciesViewWidget({
    Key? key,
    required this.building,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buildingPolicy =
        building.buildingPolicyEn ?? building.buildingPolicyAr ?? 'Not specified';
    final cancellationPolicy =
        building.cancelationPolicyAr ?? building.cancelationPolicyEn ?? 'Not specified';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Building Policy
        _buildPolicySection(
          title: getTextByKey(key: TranslationKey.keyBuildingPolicy),
          content: buildingPolicy,
          icon: Icons.policy,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 16),

        // Cancellation Policy
        _buildPolicySection(
          title: getTextByKey(key: TranslationKey.keyCancellationPolicy),
          content: cancellationPolicy,
          icon: Icons.cancel,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 16),

        // Contact Information
        // _buildContactSection(primaryColor),
      ],
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
    required IconData icon,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content.isEmpty ? getTextByKey(key: TranslationKey.keyNotSpecified) : content,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.5,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildContactSection(Color primaryColor) {
  //   final managementPhone = building.managementPhone ?? 'N/A';
  //   final workerPhone = building.workerPhone ?? 'N/A';
  //
  //   return Container(
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       color: primaryColor.withOpacity(0.06),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: primaryColor.withOpacity(0.15), width: 0.8),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(Icons.phone, color: primaryColor, size: 20),
  //             const SizedBox(width: 8),
  //             Text(
  //               getTextByKey(key: TranslationKey.keyContactInformation),
  //               style: const TextStyle(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w700,
  //                 letterSpacing: -0.2,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         // _buildContactRow(
  //         //   label: getTextByKey(key: TranslationKey.keyManagement),
  //         //   phone: managementPhone,
  //         //   primaryColor: primaryColor,
  //         // ),
  //         const SizedBox(height: 8),
  //         _buildContactRow(
  //           label: getTextByKey(key: TranslationKey.keyWorker),
  //           phone: workerPhone,
  //           primaryColor: primaryColor,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildContactRow({
    required String label,
    required String phone,
    required Color primaryColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Text(
          phone,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}