import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/avoid_shadowed_extension_methods_rule.dart';

import '../rule_test_harness.dart';

void main() {
  group('AvoidRedundantCollectionRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidShadowedExtensionMethodsRule().diagnosticCode.name, 'avoid_shadowed_extension_methods');
      expect(
        AvoidShadowedExtensionMethodsRule().diagnosticCode.problemMessage,
        'Avoid shadowing extension methods. Method "{0}" is already defined in the extended class.',
      );
    });

    test('reports from and of constructors for supported collections', () async {
      final unit = await resolveSource('''
class A {
  void foo() {}
}
extension AExtension on A {
  void foo() {} // This will be reported by the rule.
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidShadowedExtensionMethodsRule(), unit);

      expect(diagnostics, hasLength(1));
    });
  });

  test('reports from and of constructors for supported collections', () async {
    final unit = await resolveSource('''
class A {
  void foo() {}
}
extension AExtension on A {
  void bar() {} // This will NOT be reported by the rule.
}
''');

    final diagnostics = runAnalysisRuleOnUnit(AvoidShadowedExtensionMethodsRule(), unit);

    expect(diagnostics, isEmpty);
  });
}
