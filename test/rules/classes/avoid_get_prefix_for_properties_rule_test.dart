import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/classes/avoid_get_prefix_for_properties_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidGetPrefixForPropertiesRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidGetPrefixForPropertiesRule().diagnosticCode.name, 'avoid_get_prefix_for_properties');
    });

    test('registers field and accessor declarations', () {
      expect(registeredNodeTypes(AvoidGetPrefixForPropertiesRule()), {'FieldDeclaration', 'MethodDeclaration'});
    });

    test('reports fields, getters, and setters with a get prefix', () {
      final diagnostics = runAnalysisRule(AvoidGetPrefixForPropertiesRule(), '''
class User {
  String getName = '';
  String get getLabel => '';
  set getTitle(String value) {}
  String getaway = '';
  String get_away = '';
  String get2Value = '';
  String getNameMethod() => '';
  String name = '';
}
''');

      expect(diagnostics, hasLength(2));
    });
  });
}
