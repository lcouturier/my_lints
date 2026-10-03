import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/record/avoid_extensions_on_records_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidExtensionsOnRecordsRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidExtensionsOnRecordsRule().diagnosticCode.name, 'avoid_extensions_on_records');
    });

    test('reports extension on record type', () async {
      final unit = await resolveSource('''
extension on (String, String) {
  String get fullName => '\$1 \$2';
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidExtensionsOnRecordsRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('reports extension on record type with more than 2 fields', () async {
      final unit = await resolveSource('''

typedef Tuple = ({String firstName, String lastName});

extension on Tuple {
  String get fullName => '\$firstName \$lastName';
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidExtensionsOnRecordsRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report extension on non-record type', () async {
      final unit = await resolveSource('''
extension on String {
  String get upper => toUpperCase();
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidExtensionsOnRecordsRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
