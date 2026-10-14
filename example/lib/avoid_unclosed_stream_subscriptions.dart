import 'dart:async';

import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  late final StreamSubscription<int> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = const Stream<int>.empty().listen((_) {});
  }

  @override
  void dispose() {
    // BAD: pausing does not cancel the subscription.
    _subscription.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class CorrectExampleState extends State<ExampleWidget> {
  late final StreamSubscription<int> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = const Stream<int>.empty().listen((_) {});
  }

  @override
  void dispose() {
    // GOOD: the subscription is cancelled before the State is disposed.
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class CorrectExampleWithHelperState extends State<ExampleWidget> {
  late final StreamSubscription<int> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = const Stream<int>.empty().listen((_) {});
  }

  @override
  void dispose() {
    // GOOD: the subscription is cancelled before the State is disposed.
    _cancelSubscription();
    super.dispose();
  }

  void _cancelSubscription() {
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
