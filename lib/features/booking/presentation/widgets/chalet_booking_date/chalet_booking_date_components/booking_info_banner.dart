import 'package:flutter/material.dart';

/// A small RTL info banner with an icon and a message, used across the
/// chalet booking date screen (instructions, deposit info, etc.).
class BookingInfoBanner extends StatelessWidget {
  final IconData icon;
  final MaterialColor color;
  final String text;

  const BookingInfoBanner({
    Key? key,
    required this.icon,
    required this.color,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200, width: 1),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.shade700, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}