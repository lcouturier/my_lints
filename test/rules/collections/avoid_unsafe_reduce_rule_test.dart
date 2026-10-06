import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/avoid_unsafe_reduce_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidUnsafeReduceRule', () {
    test('reports reduce without a non-empty guard', () {
      final diagnostics = runAnalysisRule(AvoidUnsafeReduceRule(), '''
int total(List<int> values) => values.reduce((left, right) => left + right);
''');

      expect(diagnostics, hasLength(1));
    });

    test('does not report reduce guarded by isNotEmpty', () {
      final diagnostics = runAnalysisRule(AvoidUnsafeReduceRule(), '''
int? total(List<int> values) => values.isNotEmpty ? values.reduce((left, right) => left + right) : null;
''');

      expect(diagnostics, isEmpty);
    });
  });
}
