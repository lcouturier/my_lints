import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/bloc/avoid_returning_value_from_cubit_methods_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidReturningValueFromCubitMethodsRule', () {
    test('reports a public Cubit method that returns a value', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  int currentValue() => state;
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidReturningValueFromCubitMethodsRule(), unit), hasLength(1));
    });

    test('does not report private or void Cubit methods', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  int _currentValue() => state;
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidReturningValueFromCubitMethodsRule(), unit), isEmpty);
    });
  });
}
