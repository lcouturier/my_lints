import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/record/avoid_positional_record_field_access_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidPositionalRecordFieldAccessRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidPositionalRecordFieldAccessRule().diagnosticCode.name, 'avoid_positional_record_field_access');
    });

    test('reports positional record field access', () async {
      final unit = await resolveSource('''
void foo() {
  final record = (1, 2);
  print(record.\$1);
  print(record.\$2);
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidPositionalRecordFieldAccessRule(), unit);

      expect(diagnostics, hasLength(2));
    });

    test('does not report named record field access', () async {
      final unit = await resolveSource('''
void foo() {
  final record = (a: 1, b: 2);
  print(record.a);
  print(record.b);
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidPositionalRecordFieldAccessRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
