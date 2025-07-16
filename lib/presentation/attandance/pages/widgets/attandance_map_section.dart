
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:in_out_2/utils/app_colors.dart'; 

class MapSection extends StatelessWidget {
  final Set<Marker> markers;
  final LatLng initialCameraTarget;
  final Function(GoogleMapController) onMapCreated;
  final bool myLocationEnabled;
  final Function() onRefreshLocation;

  const MapSection({
    super.key,
    required this.markers,
    required this.initialCameraTarget,
    required this.onMapCreated,
    required this.myLocationEnabled,
    required this.onRefreshLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition: CameraPosition(
            target: initialCameraTarget,
            zoom: 15.0,
          ),
          markers: markers,
          myLocationButtonEnabled: false,
          myLocationEnabled: myLocationEnabled,
          zoomControlsEnabled: true,
          compassEnabled: true,
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: onRefreshLocation,
            child: Icon(Icons.my_location, color: AppColors.loginButtonColor),
          ),
        ),
      ],
    );
  }
}