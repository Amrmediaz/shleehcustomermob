import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building_details_model.dart';
import 'dart:async';

import '../../../../data/models/building_details.dart';

class ImageCarouselWidget extends StatefulWidget {
  final BuildingDetailsModel building;

  const ImageCarouselWidget({Key? key, required this.building})
      : super(key: key);

  @override
  State<ImageCarouselWidget> createState() => _ImageCarouselWidgetState();
}

class _ImageCarouselWidgetState extends State<ImageCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSliderTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(covariant ImageCarouselWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCount = oldWidget.building.buldingImages?.length ?? 0;
    final newCount = widget.building.buldingImages?.length ?? 0;
    if (oldCount != newCount) {
      _currentPage = 0;
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    _autoSliderTimer?.cancel();

    final images = widget.building.buldingImages ?? [];
    if (images.length < 2) return; // مفيش داعي للتحريك لصورة واحدة أو صفر

    _autoSliderTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final currentImages = widget.building.buldingImages ?? [];
      if (currentImages.isEmpty || !_pageController.hasClients) return;

      final nextPage = (_currentPage + 1) % currentImages.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSliderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.building.buldingImages ?? [];
    final primaryColor = const Color(0xFF6366F1);

    return SizedBox(
      height: 360,
      child: Stack(
        children: [
          images.isNotEmpty
              ? PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: images.length,
            itemBuilder: (context, i) =>
                _buildImage(images[i]['path'] ?? ''),
          )
              : Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.image_not_supported,
                  size: 56, color: Colors.grey),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.06),
                ],
              ),
            ),
          ),
          if (images.isNotEmpty)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_rounded, color: primaryColor, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      '${_currentPage + 1}/${images.length}',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      memCacheHeight: 1200,
      memCacheWidth: 800,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: Center(
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            strokeWidth: 2.5,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      ),
    );
  }
}