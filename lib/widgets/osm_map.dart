import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'popup.dart';
import '../routing/routing_client_dart.dart';

List<LatLng> currentRoute = List.empty(growable: true);

class OSMMap extends StatefulWidget {
  List<LatLng> polylinePoints;

  OSMMap({super.key, required this.polylinePoints});

  @override
  State<OSMMap> createState() => _OSMMapState();
}

class _OSMMapState extends State<OSMMap> {
  MapController mapController = MapController();

  final List<Marker> _markers = List.empty(growable: true);
  final PopupController _popupLayerController = PopupController();

  bool _isRoutingVisible = false;

  double _duration = 0.0;
  double _distance = 0.0;

  String routeToString() {
    String str = "";

    for (int i = 0; i < widget.polylinePoints.length - 1; i++) {
      str +=
          "${widget.polylinePoints[i].latitude.toString()},${widget.polylinePoints[i].longitude.toString()} ";
    }

    str +=
        "${widget.polylinePoints[widget.polylinePoints.length - 1].latitude.toString()},${widget.polylinePoints[widget.polylinePoints.length - 1].longitude.toString()}";

    return str;
  }

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
    currentRoute = widget.polylinePoints;
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
          alignment: Alignment.bottomCenter,
          child: Visibility(
            visible: _isRoutingVisible,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromRGBO(15, 86, 178, 1.0),
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: const BorderSide(
                          color: Color.fromRGBO(138, 185, 246, 1.0),
                          width: 3.0,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      var data = {
                        "route": routeToString(),
                        "duration": _duration,
                        "distance": _distance
                      };

                      await http.post(
                        Uri.parse("http://127.0.0.1:5000/add_route"),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(data),
                      );

                      currentRoute = List.empty(growable: true);

                      setState(() {
                        _isRoutingVisible = false;
                        widget.polylinePoints = List.empty(growable: true);
                      });
                    },
                    icon: const Icon(
                      color: Color.fromRGBO(140, 229, 144, 1.0),
                      Icons.check,
                      size: 30.0,
                    ),
                    label: const Text(
                      'Готово',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        PolylineLayer(
          polylineCulling: false,
          polylines: [
            Polyline(
              points: widget.polylinePoints,
              color: Colors.blue,
              strokeWidth: 5.0,
            ),
          ],
        ),
        PopupMarkerLayerWidget(
          options: PopupMarkerLayerOptions(
            popupController: _popupLayerController,
            markers: _markers,
            markerRotateAlignment:
                PopupMarkerLayerOptions.rotationAlignmentFor(AnchorAlign.top),
            popupBuilder: (BuildContext context, Marker marker) => Popup(
              marker,
              onNewPOI: (LatLng point) async {
                if (currentRoute.isEmpty && !currentRoute.contains(point)) {
                  setState(() {
                    _isRoutingVisible = true;
                  });
                }

                if (!currentRoute.contains(point)) {
                  currentRoute.add(point);

                  if (currentRoute.length >= 2) {
                    List<LngLat> currentLngLat = List.empty(growable: true);

                    for (var element in currentRoute) {
                      currentLngLat.add(
                        LngLat(lng: element.longitude, lat: element.latitude),
                      );
                    }

                    final manager = OSRMManager();
                    final road = await manager.getRoad(
                      waypoints: currentLngLat,
                      languageCode: "en",
                      roadType: RoadType.foot,
                    );

                    _duration = road.duration;
                    _distance = road.distance;

                    List<LngLat> polylineLngLat = road.polyline as List<LngLat>;
                    List<LatLng> polylineLatLng = List.empty(growable: true);

                    for (var element in polylineLngLat) {
                      polylineLatLng.add(LatLng(element.lat, element.lng));
                    }

                    setState(() {
                      widget.polylinePoints = polylineLatLng;
                    });
                  }
                } else if (currentRoute.contains(point)) {
                  currentRoute.remove(point);

                  if (currentRoute.length >= 2) {
                    List<LngLat> currentLngLat = List.empty(growable: true);

                    for (var element in currentRoute) {
                      currentLngLat.add(
                        LngLat(lng: element.longitude, lat: element.latitude),
                      );
                    }

                    final manager = OSRMManager();
                    final road = await manager.getRoad(
                      waypoints: currentLngLat,
                      languageCode: "en",
                      roadType: RoadType.foot,
                    );

                    _duration = road.duration;
                    _distance = road.distance;

                    List<LngLat> polylineLngLat = road.polyline as List<LngLat>;
                    List<LatLng> polylineLatLng = List.empty(growable: true);

                    for (var element in polylineLngLat) {
                      polylineLatLng.add(LatLng(element.lat, element.lng));
                    }

                    setState(() {
                      widget.polylinePoints = polylineLatLng;
                    });
                  } else {
                    setState(() {
                      widget.polylinePoints = List.empty(growable: true);
                    });
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
