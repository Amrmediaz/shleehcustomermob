import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/util/share_links.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building_details_model.dart';

import '../../../../../core/network/urls.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/widgets/message_display_widget.dart';
import '../../../data/models/building_details.dart';
import '../../bloc/flat/flats_bloc.dart';
import 'detail_components/booking_view_widget.dart';
import 'detail_components/building_info_card_widget.dart';
import 'detail_components/description _view_widget.dart';
import 'detail_components/flats_view_widget.dart';
import 'detail_components/header_widget.dart';
import 'detail_components/image_carousel_widget.dart';
import 'detail_components/location_map_widget.dart';
import 'detail_components/policies_view_widget.dart';
import 'detail_components/price_card_widget.dart';

/// Building detail page — collapsing-header concept.
///
/// The photo lives in a SliverAppBar that shrinks into a solid bar
/// with the building name as the user scrolls; everything below is
/// one continuous page, no drag handle, no overlay sheet.
///
/// Flats section is intentionally kept as the original vertical
/// FlatsViewWidgetInfiniteScroll, embedded directly in the scroll —
/// the horizontal-row variant broke the existing pagination setup,
/// so this reverts to the working layout while keeping the rest of
/// the new page structure.
class BuildingDetailWidget extends StatefulWidget {
  final BuildingDetailsModel building;

  const BuildingDetailWidget({Key? key, required this.building}) : super(key: key);

  @override
  State<BuildingDetailWidget> createState() => _BuildingDetailWidgetState();
}

class _BuildingDetailWidgetState extends State<BuildingDetailWidget> {
  static const Color _primaryColor = Color(0xFF6366F1);
  int _heroPage = 0;
  final PageController _heroController = PageController();
  Timer? _heroAutoSlideTimer;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<FlatsBloc>(context).add(
      GetFlatByBuildingIdEvent(
        body: {"page": 1, "pageSize": 20, "buildingId": widget.building.id},
      ),
    );
    _startHeroAutoSlide();
  }

  void _startHeroAutoSlide() {
    _heroAutoSlideTimer?.cancel();
    if (_images.length < 2) return;

    _heroAutoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_heroController.hasClients) return;
      final currentImages = _images;
      if (currentImages.isEmpty) return;
      final nextPage = (_heroPage + 1) % currentImages.length;
      _heroController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _heroAutoSlideTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }
  void _loadMoreFlats(int currentPage, int pageCount) {
    if (currentPage >= pageCount) return;
    final nextPage = currentPage + 1;
    BlocProvider.of<FlatsBloc>(context).add(
      GetFlatByBuildingIdEvent(
        body: {"page": nextPage, "pageSize": 20, "buildingId": widget.building.id},
      ),
    );
  }

  // ── Image resolution ──
  // BuildingDetailsModel (via its BuildingDetails base class) exposes
  // `buldingImages` — a List<Map<String, dynamic>>, each with a
  // "path" key, same shape as ChaletDetailWidget.buldingImages.
  List<dynamic> get _images => widget.building.buldingImages;

  String _imageUrl(int index) {
    final img = _images[index];
    final path = img is Map ? (img["path"] ?? img["url"] ?? "") : img.toString();
    return path.toString();
  }

  void _showImageGalleryBottomSheet() {
    int viewMode = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('معرض الصور (${_images.length})',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.black87,
                      child: Row(
                        children: [
                          Expanded(
                            child: _galleryModeButton(
                              label: 'أفقي',
                              icon: Icons.view_carousel_rounded,
                              selected: viewMode == 0,
                              onTap: () => setSheetState(() => viewMode = 0),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _galleryModeButton(
                              label: 'شبكة',
                              icon: Icons.grid_3x3_rounded,
                              selected: viewMode == 1,
                              onTap: () => setSheetState(() => viewMode = 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.black,
                        child: viewMode == 0 ? _buildHorizontalGallery() : _buildGridGallery(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _galleryModeButton({required String label, required IconData icon, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _primaryColor : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _primaryColor : Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey[400], size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalGallery() {
    if (_images.isEmpty) return const Center(child: Text('لا توجد صور', style: TextStyle(color: Colors.grey)));
    return PageView.builder(
      itemCount: _images.length,
      itemBuilder: (context, index) => Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          Center(
            child: CachedNetworkImage(
              imageUrl: _imageUrl(index),
              fit: BoxFit.contain,
              placeholder: (context, url) => const _ShimmerBox(borderRadius: 0),
              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text('${index + 1}/${_images.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridGallery() {
    if (_images.isEmpty) return const Center(child: Text('لا توجد صور', style: TextStyle(color: Colors.grey)));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: _images.length,
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: _imageUrl(index),
          fit: BoxFit.cover,
          placeholder: (context, url) => const _ShimmerBox(borderRadius: 12),
          errorWidget: (context, url, error) => Container(color: Colors.grey[800], child: const Icon(Icons.image_not_supported, size: 32, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _sectionDivider() => Divider(color: Colors.grey[200], thickness: 1, height: 1);

  Widget _sectionTitle(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
        const SizedBox(height: 4),
        Container(width: 36, height: 3, decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    final expandedHeight = MediaQuery.of(context).size.height * 0.36;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Collapsing hero header ──
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: expandedHeight,
            backgroundColor: _primaryColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _CircleIconButton(
                  icon: Icons.share_rounded,
                  onTap: () => ShareLinks.shareBuilding(
                    widget.building.id,
                    widget.building.nameEn ?? widget.building.nameAr ?? '',
                  ),
                ),
              ),
              if (images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _CircleIconButton(icon: Icons.photo_library_outlined, onTap: _showImageGalleryBottomSheet),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 14, end: 56),
              title: Text(
                widget.building.nameEn ?? widget.building.nameAr ?? 'Building',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (images.isEmpty)
                    Container(color: _primaryColor)
                  else
                    PageView.builder(
                      controller: _heroController,
                      onPageChanged: (i) => setState(() => _heroPage = i),
                      itemCount: images.length,
                      // Preloads the next/previous page's image instead of waiting for
                      // the swipe gesture to finish — removes the "blank/shimmer flash"
                      // when changing pages.
                      allowImplicitScrolling: true,
                      itemBuilder: (context, i) {
                        final targetWidth =
                        (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio)
                            .round();

                        return CachedNetworkImage(
                          imageUrl: _imageUrl(i),
                          fit: BoxFit.cover,
                          // Decode at (roughly) the on-screen size instead of the
                          // original resolution — this is usually the single biggest win
                          // for perceived speed and memory use.
                          memCacheWidth: targetWidth,
                          fadeInDuration: const Duration(milliseconds: 120),
                          fadeOutDuration: const Duration(milliseconds: 120),
                          placeholder: (context, url) => const _ShimmerBox(borderRadius: 0),
                          errorWidget: (context, url, error) => Container(color: Colors.grey[300]),
                        );
                      },
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black38],
                        stops: [0.5, 1],
                      ),
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 46,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (i) {
                          final active = i == _heroPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.white54,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Body content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 15, color: _primaryColor),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${statesEnglishToArabic[widget.building.state] ?? ''}, ${governoratesEnglishToArabic[widget.building.gouvernate] ?? ''}',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  BuildingInfoCardWidget(building: widget.building),
                  const SizedBox(height: 22),
                  _sectionDivider(),
                  const SizedBox(height: 22),

                  PriceCardWidget(building: widget.building, primaryColor: _primaryColor),
                  const SizedBox(height: 22),
                  _sectionDivider(),
                  const SizedBox(height: 22),

                  // Flats title lives here, right after price — the
                  // content itself sits in its own sliver below so
                  // its pagination/scroll logic stays undisturbed.
                  _sectionTitle('الشقق المتاحة'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            sliver: SliverToBoxAdapter(
              child: BlocBuilder<FlatsBloc, FlatsState>(
                builder: (context, state) {
                  if (state is LoadedFlatssState) {
                    return FlatsViewWidgetInfiniteScroll(
                      building: widget.building,
                      flats: state.flats,
                      primaryColor: _primaryColor,
                      onLoadMore: () => _loadMoreFlats(state.page, state.pageCount ?? 1),
                      isLoadingMore: false,
                      hasMore: !(state.lastEmpty ?? false),
                      currentPage: state.page,
                      pageCount: state.pageCount ?? 1,
                    );
                  } else if (state is LoadingFlatsState) {
                    return const _FlatsShimmerList();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionDivider(),
                  const SizedBox(height: 22),

                  _sectionTitle('الوصف'),
                  const SizedBox(height: 12),
                  DescriptionViewWidget(building: widget.building, primaryColor: _primaryColor),
                  const SizedBox(height: 22),
                  _sectionDivider(),
                  const SizedBox(height: 22),

                  _sectionTitle('الموقع على الخريطة'),
                  const SizedBox(height: 12),
                  LocationMapWidget(
                    lat: widget.building.lat,
                    lng: widget.building.lng,
                    primaryColor: _primaryColor,
                    address:
                    '${statesEnglishToArabic[widget.building.state] ?? ''}، ${governoratesEnglishToArabic[widget.building.gouvernate] ?? ''}',
                  ),
                  const SizedBox(height: 22),
                  _sectionDivider(),
                  const SizedBox(height: 22),

                  _sectionTitle('السياسات'),
                  const SizedBox(height: 12),
                  PoliciesViewWidget(building: widget.building, primaryColor: _primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({Key? key, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }
}

/// Self-contained shimmer loading box — no external `shimmer` package
/// dependency required.
class _ShimmerBox extends StatefulWidget {
  final double borderRadius;

  const _ShimmerBox({Key? key, required this.borderRadius}) : super(key: key);

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
    );
  }
}

/// Shimmer placeholder rows shown while flats are loading — vertical,
/// matching the restored vertical flats layout.
class _FlatsShimmerList extends StatelessWidget {
  const _FlatsShimmerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const SizedBox(width: 90, height: 90, child: _ShimmerBox(borderRadius: 14)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 14, width: 140, child: _ShimmerBox(borderRadius: 6)),
                    SizedBox(height: 8),
                    SizedBox(height: 12, width: 90, child: _ShimmerBox(borderRadius: 6)),
                    SizedBox(height: 8),
                    SizedBox(height: 16, width: 70, child: _ShimmerBox(borderRadius: 6)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}