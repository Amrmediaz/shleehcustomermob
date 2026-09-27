import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../../core/strings/assets_path.dart';
import '../../../domain/entities/chalet_map.dart';
import '../../bloc/chalets/chalets_bloc.dart';
import '../../pages/chalet_detail_page.dart';

class ChaletMapWidget extends StatefulWidget {
  final List<ChaletMap> chalets;
  const ChaletMapWidget({required this.chalets});

  @override
  State<ChaletMapWidget> createState() => _ChaletMapWidgetState();
}

class _ChaletMapWidgetState extends State<ChaletMapWidget> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  late PageController _pageController;
  int _currentChaletIndex = 0;
  String _searchQuery = '';
  bool _isLoading = true;

  static const Color primaryColor = Color(0xFF6366F1);
  static const Color accentColor = Color(0xFFF97316);

  LatLng get _center => widget.chalets.isNotEmpty
      ? LatLng(
      double.tryParse(widget.chalets.first.lat) ?? 17.0322,
      double.tryParse(widget.chalets.first.lng) ?? 54.1425)
      : const LatLng(17.0322, 54.1425);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _initializeMap();
  }

  // ✅ Initialize with loading
  void _initializeMap() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _createMarkers();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  void _createMarkers() {
    final filteredChalets = _searchQuery.isEmpty
        ? widget.chalets
        : widget.chalets
        .where((chalet) =>
        chalet.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final newMarkers = filteredChalets.map((chalet) {
      return Marker(
        markerId: MarkerId("${chalet.id}"),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
        position: LatLng(
          double.tryParse(chalet.lat) ?? 0.0,
          double.tryParse(chalet.lng) ?? 0.0,
        ),
        infoWindow: InfoWindow(
          title: chalet.name,
          snippet: 'اضغط للمزيد من التفاصيل',
        ),
        onTap: () {
          final index = filteredChalets.indexOf(chalet);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          _navigateToChaletDetails(chalet.id);
        },
      );
    }).toSet();

    setState(() => markers = newMarkers);
  }

  void _navigateToChaletDetails(int id) {
    context.read<ChaletsBloc>().add(LoadChaletsById(id: "$id"));
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: ChaletDetailPage(chaletId: "$id"),
      withNavBar: false,
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _createMarkers();
    });
  }

  void _animateToChalet(ChaletMap chalet) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            double.tryParse(chalet.lat) ?? 0.0,
            double.tryParse(chalet.lng) ?? 0.0,
          ),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredChalets = _searchQuery.isEmpty
        ? widget.chalets
        : widget.chalets
        .where((chalet) =>
        chalet.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Satellite Map
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 10.0),
            onMapCreated: (controller) => mapController = controller,
            markers: markers,
            mapType: MapType.satellite,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),

          // ✅ Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'جاري تحميل الشاليهات...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1F2E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'يرجى الانتظار قليلاً',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ✅ Custom Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AssetsPath.backSvg,
                    width: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF1A1F2E),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ✅ Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 70,
            right: 16,
            child: _buildSearchBar(),
          ),

          // ✅ Large Chalets Carousel at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildChaletsCarousel(filteredChalets),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'ابحث عن شاليه...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 18),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
            onTap: () {
              _onSearchChanged('');
            },
            child: Icon(Icons.close_rounded, color: Colors.grey[400], size: 18),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        ),
        style: const TextStyle(fontSize: 13),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildChaletsCarousel(List<ChaletMap> filteredChalets) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.43,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ Drag Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ✅ Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اكتشف الشاليهات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1F2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'اسحب للمزيد ←',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${filteredChalets.length} شاليه',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Chalets Carousel
          Expanded(
            child: filteredChalets.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد شاليهات مطابقة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                setState(() => _currentChaletIndex = index);
                if (index < filteredChalets.length) {
                  _animateToChalet(filteredChalets[index]);
                }
              },
              itemCount: filteredChalets.length,
              itemBuilder: (context, index) {
                final chalet = filteredChalets[index];
                return _buildLargeChaletCard(chalet, index, filteredChalets.length);
              },
            ),
          ),

          // ✅ Pagination Dots
          if (filteredChalets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  filteredChalets.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentChaletIndex ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentChaletIndex
                          ? primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Redesigned card — the old version printed raw lat/lng numbers
  /// ("خط الطول: 17.03...") straight onto the card, which reads like
  /// leftover debug output rather than something a user should see. The
  /// map API only gives us id/name/lat/lng (no photo, price, or address),
  /// so instead of fabricating data this leans on an icon + badge layout
  /// and a position counter ("2/7") so the card still feels complete
  /// without pretending to show info we don't actually have.
  Widget _buildLargeChaletCard(ChaletMap chalet, int index, int total) {
    return GestureDetector(
      onTap: () => _navigateToChaletDetails(chalet.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.villa_rounded, size: 22, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chalet.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1F2E),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_rounded, size: 12, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              'مثبت على الخريطة',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}/$total',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToChaletDetails(chalet.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                label: const Text(
                  'عرض التفاصيل الكاملة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}