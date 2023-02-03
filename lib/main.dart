import 'package:flutter/material.dart';
import 'widgets/top_navigation_bar.dart';
import 'widgets/osm_map.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white30,
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: TopNavigationBar(),
            ),
            Expanded(
              flex: 11,
              child: OSMMap(),
            ),
          ],
        ),
      ),
    );
  }
}
