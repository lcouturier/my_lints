import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/avoid_nullable_bool_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidNullableBoolRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidNullableBoolRule().diagnosticCode.name, 'avoid_nullable_bool');
    });

    test('registers the named type nodes inspected by the rule', () {
      expect(registeredNodeTypes(AvoidNullableBoolRule()), contains('NamedType'));
    });

    test('reports a nullable bool parameter', () async {
      final unit = await resolveSource('void update(bool? value) {}');
      expect(runAnalysisRuleOnUnit(AvoidNullableBoolRule(), unit), hasLength(1));
    });

    test('does not reports a non-nullable bool parameter', () async {
      final unit = await resolveSource('void update(bool value) {}');
      expect(runAnalysisRuleOnUnit(AvoidNullableBoolRule(), unit), isEmpty);
    });

    test('does not report a nullable bool parameter in copyWith Method', () async {
      final unit = await resolveSource('''
class A {
  final bool value;
  A({required this.value});
  A copyWith({bool? value}) {
    return A(value: value ?? this.value);
  }
}
''');
      expect(runAnalysisRuleOnUnit(AvoidNullableBoolRule(), unit), isEmpty);
    });
  });
}
