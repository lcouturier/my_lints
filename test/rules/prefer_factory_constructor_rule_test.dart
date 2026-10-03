import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/prefer_factory_constructor_rule.dart';

import '../rule_test_harness.dart';

void main() {
  group('PreferFactoryConstructorRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferFactoryConstructorRule();

      expect(rule.diagnosticCode.name, 'prefer_factory_constructor');
      expect(
        rule.diagnosticCode.problemMessage,
        'Prefer using factory constructors instead of static methods for object creation.',
      );
      expect(rule.diagnosticCode.correctionMessage, null);
    });
  });

  group('PreferFactoryConstructorRule', () {
    test('reports static methods that create instances of the same class', () async {
      final unit = await resolveSource('''
 class MyClass {
   static MyClass create() => MyClass();
 }
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferFactoryConstructorRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report factory constructors', () async {
      final unit = await resolveSource('''
  class MyClass {
   factory MyClass.create() => MyClass();
 }
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferFactoryConstructorRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
