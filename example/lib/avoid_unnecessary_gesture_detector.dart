import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(child: Container()); // Lint
  }
}

class MyWidgetOk extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(child: Container(), onTap: () {});
  }
}
