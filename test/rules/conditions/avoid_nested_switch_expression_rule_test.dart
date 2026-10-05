import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_nested_switch_expression_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidNestedSwitchExpressionRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidNestedSwitchExpressionRule().diagnosticCode.name, 'avoid_nested_switch_expression_rule');
    });

    test('reports nested switch expressions', () {
      final diagnostics = runAnalysisRule(
        AvoidNestedSwitchExpressionRule(),
        '''
void f(int x, int y) {
  final value = switch (x) {
    1 => switch (y) {
      2 => 3,
      _ => 4,
    },
    _ => 0,
  };
}
''',
      );

      expect(diagnostics, hasLength(1));
    });

    test('does not report flat switch expressions', () {
      final diagnostics = runAnalysisRule(
        AvoidNestedSwitchExpressionRule(),
        '''
void f(int x) {
  final value = switch (x) {
    1 => 2,
    _ => 0,
  };
}
''',
      );

      expect(diagnostics, isEmpty);
    });
  });
}
