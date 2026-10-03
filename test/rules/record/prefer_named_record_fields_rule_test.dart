import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/record/prefer_named_record_fields_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferNamedRecordFieldsRule', () {
    test('exposes the expected diagnostic code', () {
      expect(PreferNamedRecordFieldsRule().diagnosticCode.name, 'prefer_named_record_fields');
    });

    test('reports record type without named fields', () async {
      final unit = await resolveSource('''
typedef MyRecord = (String, String);
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferNamedRecordFieldsRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('reports record type with named fields', () async {
      final unit = await resolveSource('''
typedef MyRecord = ({String name, int age});
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferNamedRecordFieldsRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports record type without named fields', () async {
      final unit = await resolveSource('''
void foo() {
  final record = (1, 2);
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferNamedRecordFieldsRule(), unit);

      expect(diagnostics, hasLength(1));
    });
  });
}
