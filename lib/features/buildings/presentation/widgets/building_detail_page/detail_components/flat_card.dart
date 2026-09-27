import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../../core/strings/language.dart';
import '../../../../../../core/widgets/today_offer_widgets.dart';
import '../../../../../booking/presentation/pages/chalet_booking_date_page.dart';
import '../../../../domain/entities/flat.dart';
import 'flat_detail_modal.dart';

/// A single flat card used inside the flats grid.
///
/// Design goals for this pass:
/// - One clear primary action ("احجز الآن") and one lighter secondary
///   action ("التفاصيل") instead of two visually equal buttons
///   competing for attention.
/// - Price shown as a bold pill anchored on a bottom gradient over the
///   photo (Airbnb-style), instead of a small boxy badge — reads
///   faster at a glance.
/// - Bed/bath specs merged into a single row with a separator dot
///   instead of two separate chip containers — less boxy, calmer.
/// - Shimmer loading placeholder instead of a spinner, consistent
///   with the rest of the app.
class FlatCardWidget extends StatelessWidget {
  final Flat flat;
  final Color primaryColor;

  const FlatCardWidget({Key? key, required this.flat, required this.primaryColor}) : super(key: key);

  void _navigateToBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChaletBookingPage(chalet: flat, isChalet: false),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FlatDetailsBottomSheet(
        flatId: flat.id,
        primaryColor: primaryColor,
        onBook: () => _navigateToBooking(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _buildImage()),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${flat.nameAr ?? ''}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: Color(0xFF1A1F2E),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildSpecsRow(),
                    const SizedBox(height: 10),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: flat.coverimg,
          fit: BoxFit.cover,
          memCacheWidth: 400,
          placeholder: (context, url) => const _ShimmerBox(),
          errorWidget: (context, url, error) => Container(
            color: const Color(0xFFF5F5F5),
            child: Icon(Icons.image_not_supported_outlined, size: 28, color: Colors.grey[400]),
          ),
        ),

        // Bottom gradient so the price pill stays legible over any photo.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
              ),
            ),
          ),
        ),

        // Price pill, bottom-left — solid background so it stays
        // readable regardless of what's underneath in the photo.
        Positioned(
          left: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.72),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  (flat.price_per_night == null || flat.price_per_night.toString().isEmpty)
                      ? "-"
                      : flat.price_per_night.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  getTextByKey(key: TranslationKey.keyOMR),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Today's Offer badge, top-left — only when the building's
        // last-minute discount applies today.
        if (flat.todayOfferActive)
          Positioned(
            top: 8,
            left: 8,
            child: TodayOfferBadge(percent: flat.todayOfferPercent),
          ),
      ],
    );
  }

  Widget _buildSpecsRow() {
    final bedsLabel = (flat.bedsNumber == 0 || flat.bedsNumber == "0")
        ? getTextByKey(key: TranslationKey.keyStudio)
        : '${flat.bedsNumber}';

    return Row(
      children: [
        Icon(Icons.bed_rounded, size: 13, color: Colors.grey[500]),
        const SizedBox(width: 3),
        Text(
          bedsLabel,
          style: TextStyle(fontSize: 11.5, color: Colors.grey[600], fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Icon(Icons.bathtub_rounded, size: 13, color: Colors.grey[500]),
        const SizedBox(width: 3),
        Text(
          '${flat.bathroomsNumber}',
          style: TextStyle(fontSize: 11.5, color: Colors.grey[600], fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Primary action — book. Given the most visual weight.
        Expanded(
          child: SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: () => _navigateToBooking(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              ),
              child: const Text(
                'احجز الآن',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Secondary action — details. Icon-only, light, doesn't
        // compete with the primary CTA for attention.
        SizedBox(
          width: 32,
          height: 32,
          child: OutlinedButton(
            onPressed: () => _showDetails(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            ),
            child: Icon(Icons.info_outline_rounded, size: 15, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}

/// Self-contained shimmer loading box — no external `shimmer` package
/// dependency required.
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({Key? key}) : super(key: key);

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final dx = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(-1 + dx, 0),
              end: Alignment(1 + dx, 0),
              colors: const [Color(0xFFE8E8E8), Color(0xFFF6F6F6), Color(0xFFE8E8E8)],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: Container(color: const Color(0xFFE8E8E8)),
        );
      },
    );
  }
}