import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemCount: 10, itemBuilder: (context, index) => Text('Item $index'));
  }
}

class MyWidgetWithPrototypeItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => Text('Item $index'),
      prototypeItem: Text('Item 1'),
    );
  }
}

class MyWidgetClassic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text('Item 1'),
        Text('Item 2'),
        Text('Item 3'),
        Text('Item 4'),
        Text('Item 5'),
        Text('Item 6'),
        Text('Item 7'),
        Text('Item 8'),
        Text('Item 9'),
        Text('Item 10'),
      ],
    );
  }
}
