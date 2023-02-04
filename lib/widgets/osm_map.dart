import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class OSMMap extends StatefulWidget {
  const OSMMap({super.key});

  @override
  State<OSMMap> createState() => _OSMMapState();
}

class _OSMMapState extends State<OSMMap> {
  MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        bounds: LatLngBounds(
          LatLng(55.82414, 37.61374),
          LatLng(55.84199, 37.64073),
        ),
        maxZoom: 18,
      ),
      nonRotatedChildren: [
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () {
                    LatLng currentCenter = mapController.center;
                    double currentZoom = mapController.zoom;

                    mapController.move(currentCenter, currentZoom + 1);
                  },
                  child: const Icon(
                    Icons.add,
                    size: 30,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () {
                    LatLng currentCenter = mapController.center;
                    double currentZoom = mapController.zoom;

                    mapController.move(currentCenter, currentZoom - 1);
                  },
                  child: const Icon(
                    Icons.remove,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.vdnh_navigator.app',
          subdomains: const ['a', 'b', 'c'],
        ),
      ],
    );
  }
}
