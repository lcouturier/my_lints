import 'package:flutter/material.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _value = 0;

  Future<void> loadWithoutMountedCheck() async {
    final value = await Future.value(1);
    setState(() => _value = value); // LINT
  }

  Future<void> loadSafely() async {
    final value = await Future.value(1);
    if (!mounted) return;
    setState(() => _value = value);
  }

  @override
  Widget build(BuildContext context) => Text('$_value');
}
