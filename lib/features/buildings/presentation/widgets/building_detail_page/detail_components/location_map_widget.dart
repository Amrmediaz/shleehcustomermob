import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows the building location on an embedded satellite/hybrid map with a
/// marker, plus a button to open turn-by-turn directions in the device's
/// maps app.
///
/// Requires the `google_maps_flutter` and `url_launcher` packages, and a
/// Google Maps API key configured for Android
/// (`android/app/src/main/AndroidManifest.xml`) and iOS
/// (`ios/Runner/AppDelegate.swift` / Info.plist) — see
/// https://pub.dev/packages/google_maps_flutter for setup steps.
class LocationMapWidget extends StatefulWidget {
  final String lat;
  final String lng;
  final String? address;
  final Color primaryColor;

  const LocationMapWidget({
    Key? key,
    required this.lat,
    required this.lng,
    required this.primaryColor,
    this.address,
  }) : super(key: key);

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  MapType _mapType = MapType.hybrid; // satellite + road labels
  GoogleMapController? _controller;

  double? get _latitude => double.tryParse(widget.lat);
  double? get _longitude => double.tryParse(widget.lng);

  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == MapType.hybrid ? MapType.satellite : MapType.hybrid;
    });
  }

  Future<void> _openDirections() async {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null) return;

    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = _latitude;
    final lng = _longitude;

    if (lat == null || lng == null) {
      return _buildUnavailablePlaceholder();
    }

    final position = LatLng(lat, lng);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 180,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: position, zoom: 16),
                  mapType: _mapType,
                  markers: {
                    Marker(markerId: const MarkerId('building_location'), position: position),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  onMapCreated: (controller) => _controller = controller,
                  onTap: (_) => _openFullMapSheet(context, position),
                ),
                // Tap-to-expand hint overlay
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: () => _openFullMapSheet(context, position)),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _MapIconButton(
                    icon: _mapType == MapType.hybrid ? Icons.map_rounded : Icons.satellite_alt_rounded,
                    onTap: _toggleMapType,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: _MapIconButton(icon: Icons.open_in_full_rounded, onTap: () => _openFullMapSheet(context, position)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (widget.address != null && widget.address!.isNotEmpty)
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 15, color: widget.primaryColor),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        widget.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Spacer(),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _openDirections,
              style: TextButton.styleFrom(
                foregroundColor: widget.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              icon: const Icon(Icons.directions_rounded, size: 16),
              label: const Text('الاتجاهات', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }

  void _openFullMapSheet(BuildContext context, LatLng position) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FullMapSheet(
        position: position,
        mapType: _mapType,
        primaryColor: widget.primaryColor,
        onOpenDirections: _openDirections,
      ),
    );
  }

  Widget _buildUnavailablePlaceholder() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_rounded, color: Colors.grey[400], size: 26),
            const SizedBox(height: 6),
            Text('الموقع غير متاح', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 16, color: Colors.grey[800]),
        ),
      ),
    );
  }
}

/// Full-screen-ish draggable map shown when the user taps to expand the
/// small preview map.
class _FullMapSheet extends StatefulWidget {
  final LatLng position;
  final MapType mapType;
  final Color primaryColor;
  final VoidCallback onOpenDirections;

  const _FullMapSheet({
    required this.position,
    required this.mapType,
    required this.primaryColor,
    required this.onOpenDirections,
  });

  @override
  State<_FullMapSheet> createState() => _FullMapSheetState();
}

class _FullMapSheetState extends State<_FullMapSheet> {
  late MapType _mapType = widget.mapType;

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
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.zero),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(target: widget.position, zoom: 17),
                        mapType: _mapType,
                        markers: {
                          Marker(markerId: const MarkerId('building_location'), position: widget.position),
                        },
                        zoomControlsEnabled: true,
                        myLocationButtonEnabled: false,
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _MapIconButton(
                          icon: _mapType == MapType.hybrid ? Icons.map_rounded : Icons.satellite_alt_rounded,
                          onTap: () => setState(() {
                            _mapType = _mapType == MapType.hybrid ? MapType.satellite : MapType.hybrid;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: widget.onOpenDirections,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.directions_rounded, color: Colors.white),
                    label: const Text(
                      'فتح الاتجاهات',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}