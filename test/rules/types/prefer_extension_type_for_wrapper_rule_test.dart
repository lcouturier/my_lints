import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/prefer_extension_type_for_wrapper_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferExtensionTypeForWrapperRule', () {
    test('reports a class wrapping a single final value', () async {
      final unit = await resolveSource('''
class UserId {
  final String value;
  const UserId(this.value);
  bool get isValid => value.isNotEmpty;
}
''');

      expect(runAnalysisRuleOnUnit(PreferExtensionTypeForWrapperRule(), unit), hasLength(1));
    });

    test('does not report a class with multiple fields', () async {
      final unit = await resolveSource('''
class User {
  final String name;
  final int age;
  User(this.name, this.age);
}
''');

      expect(runAnalysisRuleOnUnit(PreferExtensionTypeForWrapperRule(), unit), isEmpty);
    });

    test('does not report a class with a static field', () async {
      final unit = await resolveSource('''
class UserId {
  static const String kind = 'user';
  final String value;
  const UserId(this.value);
}
''');

      expect(runAnalysisRuleOnUnit(PreferExtensionTypeForWrapperRule(), unit), isEmpty);
    });

    test('does not report a class with an injected service parameter', () async {
      final unit = await resolveSource('''
class AnalyticsService {}

class UserId {
  final String value;
  const UserId(this.value, AnalyticsService analyticsService);
}
''');

      expect(runAnalysisRuleOnUnit(PreferExtensionTypeForWrapperRule(), unit), isEmpty);
    });

    test('does not report a class extending another class', () async {
      final unit = await resolveSource('''
class MyException implements Exception {
  final String message;
  MyException(this.message);
}
''');

      expect(runAnalysisRuleOnUnit(PreferExtensionTypeForWrapperRule(), unit), isEmpty);
    });

    test('does not report an abstract class', () async {
      final unit = await resolveSource('''
abstract class Wrapper {
  final String value;
  Wrapper(this.value);
}
''');

      expect(runAnalysisRuleOnUnit(PreferExtensionTypeForWrapperRule(), unit), isEmpty);
    });

    test('does not report a class without a constructor initializing the field', () async {
      final unit = await resolveSource('''
class Wrapper {
  final String value;
}
''');

      expect(runAnalysisRuleOnUnit(PreferExtensionTypeForWrapperRule(), unit), isEmpty);
    });

    test('does not report a class where the field is not initialized by the constructor', () async {
      final unit = await resolveSource('''
class Wrapper {
  final String value;
  Wrapper();
}
''');

      expect(runAnalysisRuleOnUnit(PreferExtensionTypeForWrapperRule(), unit), isEmpty);
    });
  });
}
