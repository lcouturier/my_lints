import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/prefer_if_case_over_is_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferIfCaseOverIsRule', () {
    test('registers an if statement processor', () {
      expect(registeredNodeTypes(PreferIfCaseOverIsRule()), {'IfStatement'});
    });

    test('reports a type check followed by property access on the value', () {
      expect(
        runAnalysisRule(
          PreferIfCaseOverIsRule(),
          'void f(Object state) { if (state is ErrorState) { print(state.error); } }',
        ),
        hasLength(1),
      );
    });

    test('does not report a type check without property access', () {
      expect(
        runAnalysisRule(
          PreferIfCaseOverIsRule(),
          'void f(Object state) { if (state is ErrorState) { print(state); } }',
        ),
        isEmpty,
      );
    });

    test('does not report a negated type check', () {
      expect(
        runAnalysisRule(
          PreferIfCaseOverIsRule(),
          'void f(Object state) { if (state is! ErrorState) { print(state.error); } }',
        ),
        isEmpty,
      );
    });

    test('does not report property access on a different value', () {
      expect(
        runAnalysisRule(
          PreferIfCaseOverIsRule(),
          'void f(Object state, Object other) { if (state is ErrorState) { print(other.error); } }',
        ),
        isEmpty,
      );
    });
  });
}
