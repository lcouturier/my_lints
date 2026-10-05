import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/avoid_nullable_bool_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidNullableBoolRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidNullableBoolRule().diagnosticCode.name, 'avoid_nullable_bool');
    });

    test('registers the named type nodes inspected by the rule', () {
      expect(registeredNodeTypes(AvoidNullableBoolRule()), contains('NamedType'));
    });
  });
}
