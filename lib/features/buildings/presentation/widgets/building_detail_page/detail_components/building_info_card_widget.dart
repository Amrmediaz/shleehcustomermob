import 'package:flutter/material.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building_details_model.dart';

import '../../../../../../core/strings/language.dart';
import '../../../../data/models/building_details.dart';

class BuildingInfoCardWidget extends StatelessWidget {
  final BuildingDetailsModel building;

  const BuildingInfoCardWidget({Key? key, required this.building})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6366F1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!, width: 0.8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoItem(
                icon: Icons.layers,
                label:                   getTextByKey(key: TranslationKey.keyFloors),

                value: '${building.totalFloor ?? 'N/A'}',
                primaryColor: primaryColor,
              ),
              _buildDivider(),
              _buildInfoItem(
                icon: Icons.apartment,
                label: getTextByKey(key: TranslationKey.keyUnits),
                value: '${building.totalFlats ?? 'N/A'}',
                primaryColor: primaryColor,
              ),
              _buildDivider(),
              _buildInfoItem(
                icon: Icons.calendar_today,
                label:getTextByKey(key: TranslationKey.keyYear),
                value: '${building.yearBuilt ?? 'N/A'}',
                primaryColor: primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeItem(
                icon: Icons.login,
                label: getTextByKey(key: TranslationKey.keyCheckIn),
                time: building.checkIn ?? 'N/A',
                primaryColor: primaryColor,
              ),
              _buildDivider(),
              _buildTimeItem(
                icon: Icons.logout,
                label: getTextByKey(key: TranslationKey.keyCheckOut),
                time: building.checkOut ?? 'N/A',
                primaryColor: primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color primaryColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 22, color: primaryColor),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey[900],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeItem({
    required IconData icon,
    required String label,
    required String time,
    required Color primaryColor,
  }) {
    final displayTime = time.length >= 5 ? time.substring(0, 5) : time;

    return Column(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(height: 3),
        Text(
          displayTime,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey[300],
    );
  }
}