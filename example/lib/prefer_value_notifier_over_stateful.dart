import 'package:flutter/material.dart';

// BAD: Simple StatefulWidget with one mutable field
class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() => _count++),
      child: Text('$_count'),
    );
  }
}

// GOOD: StatelessWidget with ValueNotifier
class CounterWidgetGood extends StatelessWidget {
  final ValueNotifier<int> countNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: countNotifier,
      builder: (context, count, child) {
        return ElevatedButton(
          onPressed: () => countNotifier.value++,
          child: Text('$count'),
        );
      },
    );
  }
}
