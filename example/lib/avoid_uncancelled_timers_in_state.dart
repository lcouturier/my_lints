import 'dart:async';

import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {});
  }

  @override
  void dispose() {
    // BAD: the timer continues running after this State is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class CorrectExampleState extends State<ExampleWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
