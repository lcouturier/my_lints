import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_cascade_after_if_null_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidCascadeAfterIfNullRule', () {
    test('reports a cascade on an if-null expression', () {
      expect(
        runAnalysisRule(AvoidCascadeAfterIfNullRule(), 'final value = nullable ?? Object()..toString();'),
        hasLength(1),
      );
    });

    test('does not report an ordinary cascade', () {
      expect(runAnalysisRule(AvoidCascadeAfterIfNullRule(), 'void f(Object value) { value..toString(); }'), isEmpty);
    });
  });
}
