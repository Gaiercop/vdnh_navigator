import 'package:flutter/material.dart';

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

                  Text(
                    '$sub1 · $sub2',
                    maxLines: 1,
                    style: const TextStyle(
                        fontFamily: 'Lato',
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 15),
                  ),
                ],
              ), //Column
            ),
          ),
        ]));
  }
}
