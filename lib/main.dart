import 'package:flutter/material.dart';
import 'widgets/osm_map.dart';
import 'widgets/display_routes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white30,
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: NavigationBar(
                backgroundColor: Colors.white,
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                selectedIndex: currentPageIndex,
                destinations: const <Widget>[
                  NavigationDestination(
                    icon: Icon(Icons.route_rounded),
                    label: 'Построить маршрут',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.bookmark),
                    icon: Icon(Icons.bookmark_border),
                    label: 'Ваши маршруты',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.question_mark_rounded),
                    label: 'О сайте',
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 11,
              child: <Widget>[
                OSMMap(
                  polylinePoints: [],
                ),
                const RoutesList(),
                Container(
                  color: Colors.white70,
                  alignment: Alignment.topLeft,
                  child: const Text('О сайте'),
                ),
              ][currentPageIndex],
            ),
          ],
        ),
      ),
    );
  }
}
