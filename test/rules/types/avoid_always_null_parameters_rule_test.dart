import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/avoid_always_null_parameters_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidAlwaysNullParametersRule', () {
    test('reports a nullable parameter only called with null', () async {
      final unit = await resolveSource('''
void update(String? value) {}
void caller() { update(null); }
''');

      expect(runAnalysisRuleOnUnit(AvoidAlwaysNullParametersRule(), unit), hasLength(1));
    });

    test('does not report a nullable parameter called with a value', () async {
      final unit = await resolveSource('''
void update(String? value) {}
void caller() { update('ready'); }
''');

      expect(runAnalysisRuleOnUnit(AvoidAlwaysNullParametersRule(), unit), isEmpty);
    });
  });
}
