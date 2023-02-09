import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'new_route.dart';
import 'osm_map.dart';

typedef AddPOICallback = void Function(LatLng point);

class Popup extends StatefulWidget {
  final Marker marker;
  final AddPOICallback onNewPOI;

  const Popup(this.marker, {Key? key, required this.onNewPOI})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PopupState();
}

class _PopupState extends State<Popup> {
  Future<String>? _name;

  @override
  initState() {
    super.initState();

    _name = _getName(LatLng(
      widget.marker.point.latitude,
      widget.marker.point.longitude,
    ));
  }

  void addPOI(bool isCreated) {
    if (isCreated == true) {
      widget.onNewPOI(
        LatLng(
          widget.marker.point.latitude,
          widget.marker.point.longitude,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          if (currentRoute.isEmpty) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CreateRoute(
                  onRouteCreated: (bool isCreated) {
                    addPOI(isCreated);
                  },
                );
              },
            );
          } else {
            addPOI(true);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 10),
              child: Icon(Icons.add_location),
            ),
            _cardDescription(context),
          ],
        ),
      ),
    );
  }

  Widget _cardDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FutureBuilder<String>(
                future: _name,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                        color: Colors.black54);
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                      snapshot.data as String,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                      ),
                    );
                  } else {
                    return Text('State: ${snapshot.connectionState}');
                  }
                }),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            Text(
              'Координаты: ${widget.marker.point.latitude}, ${widget.marker.point.longitude}',
              style: const TextStyle(fontSize: 12.0),
            ),
            Text(
              'Marker size: ${widget.marker.width}, ${widget.marker.height}',
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }

  Future<String>? _getName(LatLng coords) async {
    var data = {"latitude": coords.latitude, "longitude": coords.longitude};

    final result = await http.post(
      Uri.parse("http://127.0.0.1:5000/get_sight_name"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    return result.body;
  }
}
