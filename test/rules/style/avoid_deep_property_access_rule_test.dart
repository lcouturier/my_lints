import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_deep_property_access_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidDeepPropertyAccessRule', () {
    test('reports a property access deeper than three levels', () {
      expect(runAnalysisRule(AvoidDeepPropertyAccessRule(), 'void f() { getRoot().a.b.c.d; }'), isNotEmpty);
    });

    test('does not report a shallow property access', () {
      expect(runAnalysisRule(AvoidDeepPropertyAccessRule(), 'void f() { getRoot().a.b; }'), isEmpty);
    });
  });
}
