import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:navigator_site/widgets/osm_map.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({
    Key? key,
    required this.title,
    required this.sub1,
    required this.sub2,
  }) : super(key: key);

  final String title;
  final String sub1;
  final String sub2;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(children: <Widget>[
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20),
                  ), //Text

                  const Padding(padding: EdgeInsets.only(bottom: 2.0)),

                  Row(
                    children: [
                      Text(
                        '$sub1 · $sub2',
                        maxLines: 1,
                        style: const TextStyle(
                            fontFamily: 'Lato',
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                            fontSize: 15),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            String id = "";
                            List<LatLng> points = List.empty(growable: true);

                            for (int i = title.indexOf("№") + 1;
                                i < title.length;
                                i++) {
                              id += title[i];
                            }

                            var data = {"id": id};

                            final result = await http.post(
                              Uri.parse("http://127.0.0.1:5000/get_points"),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                              body: jsonEncode(data),
                            );

                            var pointsList = result.body.split(" ");
                            for (var element in pointsList) {
                              if (element == "") continue;

                              LatLng point = LatLng(
                                  double.parse(element.split(",")[0]),
                                  double.parse(element.split(",")[1]));

                              points.add(point);
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OSMMap(
                                  polylinePoints: points,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.map),
                          label: const Text("Показать на карте"),
                        ),
                      ),
                    ],
                  ),
                ],
              ), //Column
            ),
          ),
        ]));
  }
}
