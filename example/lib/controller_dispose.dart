// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class MyController extends ChangeNotifier {
  @override
  void dispose() {
    super.dispose();
  }
}

class MyWidget extends StatefulWidget {
  final MyController controller;

  const MyWidget({super.key, required this.controller});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final MyController _myController = MyController();
  late final MyController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}
