import 'package:flutter/material.dart';

import '../../../../domain/entities/special_price_range.dart';

/// Banner + legend showing days with special/discounted prices.
/// Dates are formatted as dd/MM/yyyy.
class SpecialPricesBanner extends StatelessWidget {
  final List<SpecialPriceRange> specialPrices;
  final bool isLoading;

  const SpecialPricesBanner({
    Key? key,
    required this.specialPrices,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading || specialPrices.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.stars_rounded, color: Colors.amber.shade700, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'أيام بأسعار خاصة، مُشار إليها بنقطة صفراء في التقويم',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: specialPrices.map((range) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Text(
                  '${formatDateYyyyMmDd(range.start)} - ${formatDateYyyyMmDd(range.end)}  •  ${range.price.toStringAsFixed(0)} ر.ع',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}