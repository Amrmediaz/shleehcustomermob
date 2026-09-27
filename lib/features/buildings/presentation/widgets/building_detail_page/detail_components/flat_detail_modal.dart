import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../../core/strings/language.dart';
import '../../../../data/models/flat_details.dart';
import 'flat_details_service.dart';

/// Bottom sheet shown when the user taps "التفاصيل" on a flat card.
/// Fetches full details from GetFlatData and renders them, with a sticky
/// "Book" button at the bottom.
///
/// This pass: the loading state is now a shimmer skeleton shaped like
/// the real content (instead of a plain spinner), the image carousel
/// has a page counter badge, and spacing/visual details were tightened
/// to match the rest of the app's design language.
class FlatDetailsBottomSheet extends StatefulWidget {
  final int flatId;
  final Color primaryColor;
  final VoidCallback onBook;

  const FlatDetailsBottomSheet({
    Key? key,
    required this.flatId,
    required this.primaryColor,
    required this.onBook,
  }) : super(key: key);

  @override
  State<FlatDetailsBottomSheet> createState() => _FlatDetailsBottomSheetState();
}

class _FlatDetailsBottomSheetState extends State<FlatDetailsBottomSheet> {
  final _service = FlatDetailsService();
  late Future<FlatDetailsModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getFlatDetails(widget.flatId);
  }

  void _retry() {
    setState(() => _future = _service.getFlatDetails(widget.flatId));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: FutureBuilder<FlatDetailsModel>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoading(scrollController);
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return _buildError();
              }
              return _buildContent(scrollController, snapshot.data!);
            },
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ── Shimmer skeleton loading state — shaped like the real content ──
  Widget _buildLoading(ScrollController scrollController) {
    return Column(
      children: [
        _buildDragHandle(),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const _ShimmerBox(height: 200, borderRadius: 16),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: const _ShimmerBox(height: 20, borderRadius: 6)),
                  const SizedBox(width: 10),
                  const SizedBox(width: 70, child: _ShimmerBox(height: 40, borderRadius: 10)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                      child: const _ShimmerBox(height: 58, borderRadius: 10),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              const _ShimmerBox(height: 14, width: 80, borderRadius: 6),
              const SizedBox(height: 10),
              const _ShimmerBox(height: 13, borderRadius: 6),
              const SizedBox(height: 6),
              const _ShimmerBox(height: 13, borderRadius: 6),
              const SizedBox(height: 6),
              const _ShimmerBox(height: 13, width: 200, borderRadius: 6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        _buildDragHandle(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'تعذر تحميل تفاصيل الوحدة',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                TextButton(onPressed: _retry, child: const Text('إعادة المحاولة')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ScrollController scrollController, FlatDetailsModel flat) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          _buildDragHandle(),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                _ImageCarousel(imageUrls: flat.galleryImageUrls, primaryColor: widget.primaryColor),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        flat.displayName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildPriceBadge(flat),
                  ],
                ),
                if (flat.stopBook) ...[
                  const SizedBox(height: 10),
                  _buildStopBookNotice(),
                ],
                const SizedBox(height: 18),
                _buildFeaturesGrid(flat),
                if (flat.displayDescription.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _sectionTitle('الوصف'),
                  const SizedBox(height: 8),
                  Text(
                    flat.displayDescription,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6),
                  ),
                ],
                if (flat.displayAdditionalDetails.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _sectionTitle('تفاصيل إضافية'),
                  const SizedBox(height: 8),
                  Text(
                    flat.displayAdditionalDetails,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6),
                  ),
                ],
                if (flat.electronicDevices.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _sectionTitle('المرافق'),
                  const SizedBox(height: 10),
                  _buildAmenitiesWrap(flat),
                ],
                if (flat.insuranceAmount > 0) ...[
                  const SizedBox(height: 18),
                  _buildInsuranceNotice(flat),
                ],
              ],
            ),
          ),
          _buildBookFooter(flat),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700));
  }

  Widget _buildPriceBadge(FlatDetailsModel flat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                flat.pricePerNight.toStringAsFixed(0),
                style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(width: 3),
              Text(
                getTextByKey(key: TranslationKey.keyOMR),
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 10),
              ),
            ],
          ),
          if (flat.weekendPricePerNight > 0)
            Text(
              'نهاية الأسبوع ${flat.weekendPricePerNight.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 9, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }

  Widget _buildStopBookNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.block_rounded, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Text(
            'الحجز متوقف مؤقتاً لهذه الوحدة',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(FlatDetailsModel flat) {
    final features = <MapEntry<IconData, String>>[
      MapEntry(
        Icons.bed_rounded,
        flat.bedsNumber == '0' || flat.bedsNumber.isEmpty
            ? getTextByKey(key: TranslationKey.keyStudio)
            : '${flat.bedsNumber} ${getTextByKey(key: TranslationKey.keyBedroom)}',
      ),
      MapEntry(Icons.bathtub_rounded, '${flat.bathroomsNumber} ${getTextByKey(key: TranslationKey.keyBathroom)}'),
      if (flat.balconiesNumber.isNotEmpty && flat.balconiesNumber != '0')
        MapEntry(Icons.balcony_rounded, flat.balconiesNumber),
      if (flat.visitorsCount > 0) MapEntry(Icons.people_alt_rounded, '${flat.visitorsCount}'),
    ];

    return Row(
      children: features
          .map((f) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(f.key, size: 18, color: widget.primaryColor),
              const SizedBox(height: 4),
              Text(
                f.value,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildAmenitiesWrap(FlatDetailsModel flat) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: flat.electronicDevices
          .map((d) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 13, color: widget.primaryColor),
            const SizedBox(width: 5),
            Text(
              d.serviceNameAr,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
          ],
        ),
      ))
          .toList(),
    );
  }

  Widget _buildInsuranceNotice(FlatDetailsModel flat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.security_rounded, size: 16, color: Colors.amber.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'مبلغ تأمين ${flat.insuranceAmount.toStringAsFixed(0)} ${getTextByKey(key: TranslationKey.keyOMR)} يُضاف للحجز',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.amber.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookFooter(FlatDetailsModel flat) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: flat.stopBook
              ? null
              : () {
            Navigator.pop(context);
            widget.onBook();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            flat.stopBook ? 'الحجز غير متاح حالياً' : 'احجز الآن',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final Color primaryColor;

  const _ImageCarousel({required this.imageUrls, required this.primaryColor});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _controller = PageController();
  int _index = 0;

  static const double _height = 200;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: _height,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Icon(Icons.image_not_supported, size: 32, color: Colors.grey[400])),
      );
    }

    final dpr = MediaQuery.of(context).devicePixelRatio;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: _height,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.imageUrls.length,
              onPageChanged: (i) => setState(() => _index = i),
              // Preload the next/previous image instead of only fetching
              // it once the swipe gesture starts.
              allowImplicitScrolling: true,
              itemBuilder: (context, i) => CachedNetworkImage(
                imageUrl: widget.imageUrls[i],
                fit: BoxFit.cover,
                width: double.infinity,
                // Decode at the actual on-screen height instead of the
                // original resolution — cuts decode time and memory a lot
                // for typical photo uploads.
                memCacheHeight: (_height * dpr).round(),
                fadeInDuration: const Duration(milliseconds: 120),
                placeholder: (context, url) => const _ShimmerBox(borderRadius: 0),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                ),
              ),
            ),
          ),
        ),

        // Page counter badge — solid background, always legible,
        // consistent with the flat card's price pill treatment.
        if (widget.imageUrls.length > 1)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_index + 1}/${widget.imageUrls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),

        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: active ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Self-contained shimmer loading box — no external `shimmer` package
/// dependency required. Used for both individual placeholders and
/// the skeleton loading state.
class _ShimmerBox extends StatefulWidget {
  final double? height;
  final double? width;
  final double borderRadius;

  const _ShimmerBox({Key? key, this.height, this.width, this.borderRadius = 8}) : super(key: key);

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
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: ShaderMask(
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
            ),
          );
        },
      ),
    );
  }
}