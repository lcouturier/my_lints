import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/avoid_nested_if_rule.dart';

import '../rule_test_harness.dart';

void main() {
  group('AvoidNestedIfRule', () {
    test('exposes the expected diagnostic code', () {
      final rule = AvoidNestedIfRule();
      expect(rule.diagnosticCode.name, 'avoid_nested_if');
      expect(rule.diagnosticCode.problemMessage, 'Avoid nested if statements.');
    });

    test('reports a nested if statement', () {
      final diagnostics = runAnalysisRule(AvoidNestedIfRule(), '''
void f(int a) {
  if (a > 0) {
    if (a < 10) {
      if (a % 2 == 0) {
        print('a is a positive even number less than 10');
      }
    }
  }
}''');

      expect(diagnostics, hasLength(1));
    });

    test('reports a replaceable null check followed by assignment', () {
      final diagnostics = runAnalysisRule(AvoidNestedIfRule(), '''
 void f(int a) {
   if (a > 0) {
     if (a < 10) {
        print('a is a positive even number less than 10');
     }
   }
 }
''');

      expect(diagnostics, isEmpty);
    });
  });
}
