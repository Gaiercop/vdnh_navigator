import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'route_card.dart';

class RoutesList extends StatefulWidget {
  const RoutesList({super.key});

  @override
  State<RoutesList> createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {
  Future<List<Widget>>? _routes;

  @override
  initState() {
    super.initState();

    _routes = _getRoutes();
  }

  Future<List<Widget>> _getRoutes() async {
    List<Widget> output = List.empty(growable: true);

    final result = await http.post(
      Uri.parse("http://127.0.0.1:5000/get_routes"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    dynamic widg = json.decode(result.body);

    for (var curr in widg) {
      output.add(RouteCard(
        title: "Маршрут №" + curr[0].toString(),
        sub1: curr[2].toStringAsFixed(2) + " sec",
        sub2: curr[3].toStringAsFixed(2) + " km",
      ));
    }

    return output;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
        future: _routes,
        builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(color: Colors.blue);
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: snapshot.data as List<Widget>,
            );
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        });
  }
}
