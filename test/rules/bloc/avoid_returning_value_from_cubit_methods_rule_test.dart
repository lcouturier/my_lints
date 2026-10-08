import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/bloc/avoid_returning_value_from_cubit_methods_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  test('reports a public Cubit method that returns a value in a Bloc', () async {
    final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterBloc extends Cubit<int> {
  CounterBloc() : super(0);

  int currentValue() => state;
}
''', useExamplePackages: true);

    expect(runAnalysisRuleOnUnit(AvoidReturningValueFromCubitMethodsRule(), unit), hasLength(1));
  });

  test('does not report private or void Bloc methods', () async {
    final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterBloc extends Cubit<int> {
  CounterBloc() : super(0);

  void increment() => emit(state + 1);
  int _currentValue() => state;
}
''', useExamplePackages: true);

    expect(runAnalysisRuleOnUnit(AvoidReturningValueFromCubitMethodsRule(), unit), isEmpty);
  });

  test('does not report non-Cubit classes', () async {
    final unit = await resolveSource('''
class Counter {
  int currentValue() => 42;
}
''', useExamplePackages: true);

    expect(runAnalysisRuleOnUnit(AvoidReturningValueFromCubitMethodsRule(), unit), isEmpty);
  });
}
