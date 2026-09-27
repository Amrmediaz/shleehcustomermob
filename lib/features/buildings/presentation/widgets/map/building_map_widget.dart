import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../../core/strings/assets_path.dart';
import '../../../domain/entities/building_map.dart';
import '../../bloc/buildings/buildings_bloc.dart';
import '../../pages/building_detail_page.dart';

/// Rebuilt to match ChaletMapWidget's design (search bar, bottom carousel,
/// loading overlay, custom back button) instead of the old bare map + plain
/// back button — the two "Map" buttons in the app should feel like the same
/// feature, not two different levels of finish.
class BuildingMapWidget extends StatefulWidget {
  final List<BuildingMap> Buildings;
  const BuildingMapWidget({required this.Buildings});

  @override
  State<BuildingMapWidget> createState() => _BuildingMapWidgetState();
}

class _BuildingMapWidgetState extends State<BuildingMapWidget> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  late PageController _pageController;
  int _currentBuildingIndex = 0;
  String _searchQuery = '';
  bool _isLoading = true;

  static const Color primaryColor = Color(0xFF6366F1);
  static const Color accentColor = Color(0xFFF97316);

  LatLng get _center => widget.Buildings.isNotEmpty
      ? LatLng(
          double.tryParse(widget.Buildings.first.lat) ?? 17.0322,
          double.tryParse(widget.Buildings.first.lng) ?? 54.1425)
      : const LatLng(17.0322, 54.1425);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _initializeMap();
  }

  void _initializeMap() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _createMarkers();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  void _createMarkers() {
    final filtered = _filteredBuildings();

    final newMarkers = filtered.map((building) {
      return Marker(
        markerId: MarkerId("${building.id}"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        position: LatLng(
          double.tryParse(building.lat) ?? 0.0,
          double.tryParse(building.lng) ?? 0.0,
        ),
        infoWindow: InfoWindow(
          title: building.name,
          snippet: 'اضغط للمزيد من التفاصيل',
        ),
        onTap: () {
          final index = filtered.indexOf(building);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          _navigateToBuildingDetails(building.id);
        },
      );
    }).toSet();

    setState(() => markers = newMarkers);
  }

  List<BuildingMap> _filteredBuildings() {
    if (_searchQuery.isEmpty) return widget.Buildings;
    return widget.Buildings
        .where((b) => b.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _navigateToBuildingDetails(int id) {
    context.read<BuildingsBloc>().add(LoadBuildingsById(id: "$id"));
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: BuildingDetailPage(buildingId: "$id"),
      withNavBar: false,
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _createMarkers();
    });
  }

  void _animateToBuilding(BuildingMap building) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            double.tryParse(building.lat) ?? 0.0,
            double.tryParse(building.lng) ?? 0.0,
          ),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBuildings = _filteredBuildings();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 10.0),
            onMapCreated: (controller) => mapController = controller,
            markers: markers,
            mapType: MapType.satellite,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),

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
                      const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'جاري تحميل الشقق...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1F2E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'يرجى الانتظار قليلاً',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),

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
                    colorFilter: const ColorFilter.mode(Color(0xFF1A1F2E), BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 70,
            right: 16,
            child: _buildSearchBar(),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBuildingsCarousel(filteredBuildings),
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
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'ابحث عن شقة...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 18),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () => _onSearchChanged(''),
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

  Widget _buildBuildingsCarousel(List<BuildingMap> filteredBuildings) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.43,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, -8)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اكتشف الشقق',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1F2E)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'اسحب للمزيد ←',
                      style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600),
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
                    '${filteredBuildings.length} شقة',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primaryColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredBuildings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد شقق مطابقة',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() => _currentBuildingIndex = index);
                      if (index < filteredBuildings.length) {
                        _animateToBuilding(filteredBuildings[index]);
                      }
                    },
                    itemCount: filteredBuildings.length,
                    itemBuilder: (context, index) {
                      final building = filteredBuildings[index];
                      return _buildLargeBuildingCard(building, index, filteredBuildings.length);
                    },
                  ),
          ),
          if (filteredBuildings.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  filteredBuildings.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentBuildingIndex ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentBuildingIndex ? primaryColor : Colors.grey[300],
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

  /// The map API only returns id/name/lat/lng for buildings (no photo,
  /// price, or address), so — same as the chalets map card — this leans on
  /// an icon + "pinned on map" badge + position counter instead of
  /// fabricating info that isn't actually available.
  Widget _buildLargeBuildingCard(BuildingMap building, int index, int total) {
    return GestureDetector(
      onTap: () => _navigateToBuildingDetails(building.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4)),
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
                  child: const Icon(Icons.apartment_rounded, size: 22, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.name,
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
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
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
                onPressed: () => _navigateToBuildingDetails(building.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                label: const Text(
                  'عرض التفاصيل الكاملة',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
