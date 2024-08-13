import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../../../../../core/strings/assets_path.dart';
import '../../../../../core/util/common_functions.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setMarkersChalets();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      children: [
        GoogleMap(
                onMapCreated: _onMapCreated,
                markers: markers,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 7.0,
                )),
        Positioned(
          top: CommonFunctions.getSafeAreaTip(context),
          left: 20,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              AssetsPath.backSvg, // Replace with your image URL
              // Adjust the height as needed
            ),
          ),
        ),
      ],
    ));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void setMarkersChalets() {
    for (var chalet in widget.chalets) {
      markers.add(Marker(
        markerId: MarkerId("${chalet.id}"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        position: LatLng(double.parse(chalet.lat), double.parse(chalet.lng)),
        infoWindow: InfoWindow(title: chalet.name,),
        onTap: () {
          BlocProvider.of<ChaletsBloc>(context)
              .add(LoadChaletsById(id: "${chalet.id}"));
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: const ChaletDetailPage(),
            withNavBar: false,
          );
        },
      ));
    }
    setState(() {
      Future.delayed(const Duration(milliseconds: 500), () {
// Here you can write your code


          _isLoading = false;

      });
    });
  }

  bool _isLoading = true;
  late GoogleMapController mapController;
  final Set<Marker> markers = {};
  final LatLng _center = const LatLng(17.0322, 54.1425);
}
