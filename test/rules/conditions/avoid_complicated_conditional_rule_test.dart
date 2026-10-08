import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_complicated_conditional_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidComplicatedConditionalRule', () {
    test('reports a condition at the configured complexity threshold', () async {
      final unit = await resolveSource('''
void f(bool a, bool b, bool c) { if (a && b && c) {} }
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidComplicatedConditionalRule(threshold: 2), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report a condition below the threshold', () async {
      final unit = await resolveSource('''
void f(bool a, bool b) { if (a && b) {} }
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidComplicatedConditionalRule(threshold: 2), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports a condition with OR operators', () async {
      final unit = await resolveSource('''
void f(bool a, bool b, bool c) { if (a || b || c) {} }
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidComplicatedConditionalRule(threshold: 2), unit);

      expect(diagnostics, hasLength(1));
    });
  });
}
