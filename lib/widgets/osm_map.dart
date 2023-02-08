import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'popup.dart';

class OSMMap extends StatefulWidget {
  const OSMMap({super.key});

  @override
  State<OSMMap> createState() => _OSMMapState();
}

class _OSMMapState extends State<OSMMap> {
  MapController mapController = MapController();

  final List<Marker> _markers = List.empty(growable: true);
  final PopupController _popupLayerController = PopupController();

  Future<List<LatLng>> getSightsCoords() async {
    final result = await http.post(
      Uri.parse("http://127.0.0.1:5000/sights"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    List<String> arr_coords = result.body.split(" ");
    arr_coords.remove('');

    List<LatLng> res = List.empty(growable: true);

    for (int i = 0; i < arr_coords.length; i += 2) {
      res.add(
          LatLng(double.parse(arr_coords[i]), double.parse(arr_coords[i + 1])));
    }

    return res;
  }

  void generateMarkers() async {
    // Only possible if you already have called getSightsCoords() method

    List<LatLng> coordinates = await getSightsCoords();

    for (int i = 0; i < coordinates.length; i++) {
      _markers.add(
        Marker(
          point: coordinates[i],
          builder: (_) =>
              const Icon(Icons.location_on, size: 40, color: Colors.red),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    generateMarkers();
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        onTap: (_, __) => _popupLayerController
            .hideAllPopups(), // Hide popup when the map is tapped.
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
        PopupMarkerLayerWidget(
          options: PopupMarkerLayerOptions(
            popupController: _popupLayerController,
            markers: _markers,
            markerRotateAlignment:
                PopupMarkerLayerOptions.rotationAlignmentFor(AnchorAlign.top),
            popupBuilder: (BuildContext context, Marker marker) =>
                ExamplePopup(marker),
          ),
        ),
      ],
    );
  }
}
