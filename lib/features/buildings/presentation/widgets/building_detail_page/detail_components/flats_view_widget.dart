import 'package:flutter/material.dart';

import '../../../../../../core/strings/language.dart';
import '../../../../data/models/building_details.dart';
import '../../../../domain/entities/building_details_model.dart';
import '../../../../domain/entities/flat.dart';
import 'flat_card.dart';

class FlatsViewWidgetInfiniteScroll extends StatefulWidget {
  final BuildingDetailsModel building;
  final Color primaryColor;
  final List<Flat> flats;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final int pageCount;

  const FlatsViewWidgetInfiniteScroll({
    Key? key,
    required this.building,
    required this.flats,
    required this.primaryColor,
    required this.onLoadMore,
    required this.isLoadingMore,
    required this.hasMore,
    required this.currentPage,
    required this.pageCount,
  }) : super(key: key);

  @override
  State<FlatsViewWidgetInfiniteScroll> createState() => _FlatsViewWidgetInfiniteScrollState();
}

class _FlatsViewWidgetInfiniteScrollState extends State<FlatsViewWidgetInfiniteScroll> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTextByKey(key: TranslationKey.keyUnits),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.flats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            var flat = widget.flats[index];
            flat.minDays = widget.building.minDays;
            flat.managmentPhone = widget.building.managementPhone;
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (index * 80)),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 16 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: FlatCardWidget(flat: flat, primaryColor: widget.primaryColor),
            );
          },
        ),

        const SizedBox(height: 16),

        if (widget.hasMore)
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: widget.isLoadingMore ? null : widget.onLoadMore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor.withOpacity(0.08),
                  foregroundColor: widget.primaryColor,
                  disabledBackgroundColor: widget.primaryColor.withOpacity(0.05),
                  elevation: 0,
                  side: BorderSide(
                    color: widget.primaryColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: widget.isLoadingMore
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
                    strokeWidth: 2.5,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20, color: widget.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'عرض المزيد',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}