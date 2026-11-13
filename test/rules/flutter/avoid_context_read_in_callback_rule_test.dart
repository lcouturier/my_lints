import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/avoid_context_read_in_callback_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidContextReadInCallbackRule', () {
    test('reports context.read<T>() inside a callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.read<CounterCubit>().increment(),
      icon: const Icon(Icons.add),
    );
  }
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidContextReadInCallbackRule(), unit), hasLength(1));
    });

    test('does not report when cubit is stored in a field', () async {
      final unit = await resolveSource('''
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
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidContextReadInCallbackRule(), unit), isEmpty);
    });

    test('does not report when context.read is not in a callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CounterCubit>();
    return IconButton(
      onPressed: cubit.increment,
      icon: const Icon(Icons.add),
    );
  }
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidContextReadInCallbackRule(), unit), isEmpty);
    });
  });
}