import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/avoid_nullable_list_return_type_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidNullableListReturnTypeRule', () {
    test('reports a nullable list parameter', () async {
      final unit = await resolveSource('void update(List<int>? values) {}');
      expect(runAnalysisRuleOnUnit(AvoidUsageOfNullableListRule(), unit), hasLength(1));
    });

    test('reports a nullable list return type', () async {
      final unit = await resolveSource('List<int>? update() { return null; }');
      expect(runAnalysisRuleOnUnit(AvoidUsageOfNullableListRule(), unit), hasLength(1));
    });

    test('does not report a non-nullable list return type', () async {
      final unit = await resolveSource('List<int> update() { return []; }');
      expect(runAnalysisRuleOnUnit(AvoidUsageOfNullableListRule(), unit), isEmpty);
    });

    test('does not report a non-nullable list parameter', () async {
      final unit = await resolveSource('void update(List<int> values) {}');
      expect(runAnalysisRuleOnUnit(AvoidUsageOfNullableListRule(), unit), isEmpty);
    });

    test('does not report a non-nullable list parameter in copyWith Method', () async {
      final unit = await resolveSource('''
class A {
  final List<int> values;
  A({required this.values});

  A copyWith({List<int>? values}) {
    return A(values: values ?? this.values);
  }
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUsageOfNullableListRule(), unit), isEmpty);
    });
  });
}
