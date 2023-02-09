import 'package:flutter/material.dart';

typedef NewRouteCallback = void Function(bool isCreated);

class CreateRoute extends StatelessWidget {
  final NewRouteCallback onRouteCreated;

  const CreateRoute({super.key, required this.onRouteCreated});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Маршрут не создан'),
      content: const Text(
        'Вы добавляете точку для посещения в несуществующий маршрут. Хотите создать новый?',
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            onRouteCreated(true);
            Navigator.pop(context);
          },
          child: const Text(
            'Да',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            onRouteCreated(false);
            Navigator.pop(context);
          },
          child: const Text(
            'Нет',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
