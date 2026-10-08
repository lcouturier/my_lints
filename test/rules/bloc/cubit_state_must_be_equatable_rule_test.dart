import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/bloc/cubit_state_must_be_equatable_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('CubitStateMustBeEquatableRule', () {
    test('reports a Cubit state that does not extend Equatable', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterState {}
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState());
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(CubitStateMustBeEquatableRule(), unit), hasLength(1));
    });

    test('does not report a Cubit state that extends Equatable', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  @override
  List<Object?> get props => [];
}
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState());
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(CubitStateMustBeEquatableRule(), unit), isEmpty);
    });

    test('does not report state classes outside a Cubit', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class OtherClass {
  void update() {}
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(CubitStateMustBeEquatableRule(), unit), isEmpty);
    });
  });
}
