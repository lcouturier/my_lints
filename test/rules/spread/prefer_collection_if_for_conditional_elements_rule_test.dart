import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/spread/prefer_collection_if_for_conditional_elements_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferCollectionIfForConditionalElementsRule', () {
    test('exposes the expected diagnostic code', () {
      expect(
        PreferCollectionIfForConditionalElementsRule().diagnosticCode.name,
        'prefer_collection_if_for_conditional_elements',
      );
    });

    test('reports a one-item conditional spread and a ternary spread', () {
      final diagnostics = runAnalysisRule(PreferCollectionIfForConditionalElementsRule(), '''
void f(bool show, int value) {
  final conditional = [if (show) ...[value]];
  final ternary = [...(show ? [value] : [])];
}
''');

      expect(diagnostics, hasLength(2));
    });

    test('does not report multiple items or a non-empty else branch', () {
      final diagnostics = runAnalysisRule(PreferCollectionIfForConditionalElementsRule(), '''
void f(bool show) {
  final values = [if (show) ...[1, 2], ...(show ? [1] : [2])];
}
''');

      expect(diagnostics, isEmpty);
    });
  });
}
