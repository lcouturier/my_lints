import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/record/avoid_nested_record_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidNestedRecordRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidNestedRecordRule().diagnosticCode.name, 'avoid_nested_record');
    });

    test('reports positional and named nested records', () {
      final diagnostics = runAnalysisRule(
        AvoidNestedRecordRule(),
        "void f() { final positional = (1, (2, 3)); final named = (count: 1, value: (label: 'x', id: 2)); }",
      );

      expect(diagnostics, hasLength(2));
    });

    test('does not report flat records', () {
      final diagnostics = runAnalysisRule(AvoidNestedRecordRule(), 'void f() { final value = (1, 2); }');

      expect(diagnostics, isEmpty);
    });
  });
}
