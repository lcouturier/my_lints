import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/prefer_void_callback_rule.dart';

import '../rule_test_harness.dart';

void main() {
  group('PreferVoidCallbackRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferVoidCallbackRule();

      expect(rule.diagnosticCode.name, 'prefer_void_callback');
      expect(rule.diagnosticCode.problemMessage, 'Prefer VoidCallback over void Function()');
    });
  });

  group('PreferVoidCallbackRule detection logic', () {
    test('matches a void function type without parameters', () {
      final diagnostics = runAnalysisRule(PreferVoidCallbackRule(), '''
class A { 
  void Function() cb; 
}
''');

      expect(diagnostics, hasLength(1));
    });

    test('matches a nullable function type', () {
      final diagnostics = runAnalysisRule(PreferVoidCallbackRule(), '''
class A { 
  void Function()? cb; 
}
''');

      expect(diagnostics, hasLength(1));
    });

    test('matches a non-void return type, replaceable by ValueGetter', () {
      final diagnostics = runAnalysisRule(PreferVoidCallbackRule(), '''
class A { 
  int Function() cb; 
}
''');

      expect(diagnostics, hasLength(1));
    });

    test('does not match when the function type has parameters', () {
      final diagnostics = runAnalysisRule(PreferVoidCallbackRule(), '''
class A { 
  void Function(int) cb; 
}
''');

      expect(diagnostics, isEmpty);
    });
  });
}
