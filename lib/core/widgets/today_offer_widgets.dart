import 'package:flutter/material.dart';

/// Shared visual language for "Today's Offer" (عرض اليوم) — an
/// owner-controlled, last-minute, day-of-only discount. Two pieces:
/// [TodayOfferBadge] (small pill for listing cards) and [TodayOfferBanner]
/// (larger banner for detail pages / booking screens).
///
/// Colors are pinned to the customer website's own Today's Offer identity
/// (shleeh_com_customer/src/presentation/components/Property/PropertyCard.css
/// — `.badge-today { background: #1E8E5A; }` and
/// `.property-card-price-note { color: #146945; }`) so the deal reads as
/// the same visual language across web and mobile instead of two different
/// colors for the same feature.
class TodayOfferColors {
  TodayOfferColors._();

  /// Exact match for the website's `.badge-today` background.
  static const Color primary = Color(0xFF1E8E5A);

  /// Exact match for the website's `.property-card-price-note` text color
  /// — used for the smaller "today only" notes/tags.
  static const Color dark = Color(0xFF146945);

  /// A slightly lighter green paired with [primary] purely for a bit of
  /// depth on the larger banner (the website has no banner equivalent to
  /// match 1:1 there); [TodayOfferBadge] uses flat [primary] to match the
  /// website's badge exactly.
  static const List<Color> gradient = [Color(0xFF27A06B), primary];
  static const Color glow = Color(0x331E8E5A);
}

/// Compact pill badge for listing cards (chalet/building/flat). Positioned
/// the same way existing badges are (top corner over the cover image) —
/// callers decide placement, this widget just renders the pill itself.
class TodayOfferBadge extends StatelessWidget {
  final int percent;

  /// Compact mode drops the icon and the "اليوم" word, showing just
  /// "-XX%" — meant for tight corners (e.g. a small list-card thumbnail)
  /// that also need to fit a favorite button in the opposite corner,
  /// where the full pill is wide enough to visually collide with it.
  final bool compact;

  const TodayOfferBadge({super.key, required this.percent, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          // Flat, not gradient — matches .badge-today on the website
          // exactly (background: #1E8E5A), which is a solid color.
          color: TodayOfferColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: TodayOfferColors.glow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '-$percent%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TodayOfferColors.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: TodayOfferColors.glow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 3),
          Text(
            'خصم $percent% اليوم',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Larger banner for detail pages and the booking screen — states the
/// discount clearly and that it only applies to today/the first night, so
/// guests aren't surprised when a multi-night booking isn't fully
/// discounted.
class TodayOfferBanner extends StatelessWidget {
  final int percent;
  final String? subtitle;

  const TodayOfferBanner({
    super.key,
    required this.percent,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: TodayOfferColors.gradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: TodayOfferColors.glow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عرض اليوم — خصم $percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle ?? 'الخصم يسري على الحجز اليوم فقط — لفترة محدودة',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
