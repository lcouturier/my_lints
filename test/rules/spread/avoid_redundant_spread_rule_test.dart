import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/spread/avoid_redundant_spread_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidRedundantSpreadRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidRedundantSpreadRule().diagnosticCode.name, 'avoid_redundant_spread');
    });

    test('reports empty, single-item, and nested spread literals', () {
      final diagnostics = runAnalysisRule(
        AvoidRedundantSpreadRule(),
        'void f() { final values = [...[], ...[1], ...[...[1, 2]]]; }',
      );

      expect(diagnostics, hasLength(3));
    });

    test('does not report a multi-item literal or a spread variable', () {
      final diagnostics = runAnalysisRule(
        AvoidRedundantSpreadRule(),
        'void f(List<int> values) { final result = [...[1, 2], ...values]; }',
      );

      expect(diagnostics, isEmpty);
    });
  });
}
