import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_magic_numbers_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidMagicNumbersRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidMagicNumbersRule().diagnosticCode.name, 'avoid_magic_numbers');
    });

    test('reports non-exempt integer and double literals', () {
      final diagnostics = runAnalysisRule(AvoidMagicNumbersRule(), 'void f() { final count = 42; final ratio = 2.5; }');

      expect(diagnostics, hasLength(2));
    });

    test('ignores documented numeric exceptions', () {
      final diagnostics = runAnalysisRule(AvoidMagicNumbersRule(), '''
const constant = 42;
@Annotation(42)
void f(List<int> values) {
  final safe = [0, 1, -1, values[2]];
  final duration = new Duration(seconds: 30);
  final date = new DateTime(2024);
}
enum Example { value(42); const Example(int value); }
''');

      expect(diagnostics, isEmpty);
    });
  });
}
