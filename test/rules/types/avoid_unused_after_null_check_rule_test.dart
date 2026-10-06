import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/avoid_unused_after_null_check_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidUnusedAfterNullCheckRule', () {
    test('reports a null-checked value unused in the guarded block', () {
      expect(
        runAnalysisRule(
          AvoidUnusedAfterNullCheckRule(),
          "void f(String? value) { if (value != null) { print('ready'); } }",
        ),
        hasLength(1),
      );
    });

    test('does not report a null-checked value used in the guarded block', () {
      expect(
        runAnalysisRule(
          AvoidUnusedAfterNullCheckRule(),
          'void f(String? value) { if (value != null) { print(value); } }',
        ),
        isEmpty,
      );
    });
  });
}
