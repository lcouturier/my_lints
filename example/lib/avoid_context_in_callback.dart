import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final CounterCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<CounterCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: cubit.increment,
      icon: const Icon(Icons.add),
    );
  }
}