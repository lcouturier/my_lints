import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/prefer_throw_exception_or_error_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferThrowExceptionOrErrorRule', () {
    test('reports throwing an instance with an Exception-named constructor', () async {
      final unit = await resolveSource('''
class CustomException {
  CustomException.Exception(String message) {}
}

void fail() {
  throw CustomException.Exception('error');
}
''');

      expect(runAnalysisRuleOnUnit(PreferThrowExceptionOrErrorRule(), unit), hasLength(1));
    });

    test('does not report throwing a specific StateError', () async {
      final unit = await resolveSource("void fail() { throw StateError('error'); }");

      expect(runAnalysisRuleOnUnit(PreferThrowExceptionOrErrorRule(), unit), isEmpty);
    });
  });
}
