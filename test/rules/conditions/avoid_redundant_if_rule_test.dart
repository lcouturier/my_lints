import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_redundant_if_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidRedundantIfRule', () {
    test('reports if-else that returns true/false', () async {
      final unit = await resolveSource('''
bool isReady(bool ready) {
  if (ready) {
    return true;
  }
  return false;
}
''');

      expect(runAnalysisRuleOnUnit(AvoidRedundantIfRule(), unit), hasLength(1));
    });

    test('reports if-else that returns false/true', () async {
      final unit = await resolveSource('''
bool isNotReady(bool ready) {
  if (ready) {
    return false;
  }
  return true;
}
''');

      expect(runAnalysisRuleOnUnit(AvoidRedundantIfRule(), unit), hasLength(1));
    });

    test('does not report when the if has an else branch', () async {
      final unit = await resolveSource('''
bool isReady(bool ready) {
  if (ready) {
    return true;
  } else {
    return false;
  }
}
''');

      expect(runAnalysisRuleOnUnit(AvoidRedundantIfRule(), unit), isEmpty);
    });

    test('does not report when the return values are not booleans', () async {
      final unit = await resolveSource('''
String label(bool ready) {
  if (ready) {
    return 'yes';
  }
  return 'no';
}
''');

      expect(runAnalysisRuleOnUnit(AvoidRedundantIfRule(), unit), isEmpty);
    });

    test('does not report when the next statement is not a return', () async {
      final unit = await resolveSource('''
void doStuff(bool ready) {
  if (ready) {
    return true;
  }
  print('done');
}
''');

      expect(runAnalysisRuleOnUnit(AvoidRedundantIfRule(), unit), isEmpty);
    });
  });
}