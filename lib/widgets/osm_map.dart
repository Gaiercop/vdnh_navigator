import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OSMMap extends StatefulWidget {
  const OSMMap({super.key});

  @override
  State<OSMMap> createState() => _OSMMapState();
}

class _OSMMapState extends State<OSMMap> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlutterMap(
        mapController: MapController(),
        options: MapOptions(
          bounds: LatLngBounds(
            LatLng(55.82414, 37.61374),
            LatLng(55.84199, 37.64073),
          ),
          maxBounds: LatLngBounds(
            LatLng(55.82414, 37.61374),
            LatLng(55.84199, 37.64073),
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.vdnh_navigator.app',
          ),
        ],
      ),
    );
  }
}
