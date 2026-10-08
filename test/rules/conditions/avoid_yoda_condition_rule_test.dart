import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_yoda_condition_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidYodaConditionsRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = AvoidYodaConditionsRule();

      expect(rule.diagnosticCode.name, 'avoid_yoda_conditions');
      expect(rule.diagnosticCode.problemMessage, 'Avoid Yoda conditions.');
      expect(rule.diagnosticCode.correctionMessage, 'Consider reordering the operands to improve readability.');
    });
  });

  group('AvoidYodaConditionsRule detection logic', () {
    test('registers every supported condition host', () async {
      final unit = await resolveSource('''
void f(int value) {
  if (1 == value) {}
  while (2 == value) {}
  do {} while (3 != value);
  for (; 4 != value;) { break; }
  final result = 5 == value ? 1 : 2;
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidYodaConditionsRule(), unit);

      expect(diagnostics, hasLength(5));
    });

    test('reports constants on the left in if, loop, and conditional expressions', () async {
      final unit = await resolveSource('''
void f(int value) {
  if (1 == value) {}
  while (2 == value) {}
  do {} while (3 != value);
  for (; 4 != value;) { break; }
  final result = 5 == value ? 1 : 2;
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidYodaConditionsRule(), unit);

      expect(diagnostics, hasLength(5));
    });

    test('reports constants on the left in while and for loop conditions', () async {
      final unit = await resolveSource('''
void f(int value) {
  while (2 == value) {}
  for (; 4 != value;) { break; }
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidYodaConditionsRule(), unit);

      expect(diagnostics, hasLength(2));
    });

    test('does not report variables on the left or two constants', () async {
      final unit = await resolveSource('''
void f(int value) { if (value == 1) {} if (1 == 2) {} }
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidYodaConditionsRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
