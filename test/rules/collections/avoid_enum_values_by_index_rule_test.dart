import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/avoid_enum_values_by_index_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidEnumValuesByIndexRule', () {
    test('reports indexing enum values', () async {
      final unit = await resolveSource('''
enum Status { ready, done }

final status = Status.values[0];
''');

      expect(runAnalysisRuleOnUnit(AvoidEnumValuesByIndexRule(), unit), hasLength(1));
    });

    test('does not report accessing an enum value by name', () async {
      final unit = await resolveSource('''
enum Status { ready, done }

final status = Status.ready;
''');

      expect(runAnalysisRuleOnUnit(AvoidEnumValuesByIndexRule(), unit), isEmpty);
    });

    test('does not report accessing an enum value by name with byName()', () async {
      final unit = await resolveSource('''
enum Status { ready, done }

final status = Status.values.byName('ready');
''');

      expect(runAnalysisRuleOnUnit(AvoidEnumValuesByIndexRule(), unit), isEmpty);
    });
  });
}
