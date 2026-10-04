import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/avoid_complex_loop_conditions_rule.dart';

import '../rule_test_harness.dart';

/// A rule that checks for complex loop conditions in `for` statements.
/// Complex loop conditions can make code harder to read and understand. This rule encourages developers to extract complex conditions into separate variables or methods for better readability.
/// example:
/// ```dart
/// for (int i = 0; i < items.length && items[i].isValid(); i++) {
///   // do something
/// }
/// ```
/// This loop condition is complex because it combines multiple conditions using the logical AND operator. A better approach would be to extract the condition into a separate variable or method, like so:
/// ```dart
/// bool isValidItem(int index) {
///   return index < items.length && items[index].isValid();
/// }
/// for (int i = 0; isValidItem(i); i++) {
///   // do something
/// }
void main() {
  group('AvoidComplexLoopConditionsRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidComplexLoopConditionsRule().diagnosticCode.name, 'avoid_complex_loop_conditions');
      expect(
        AvoidComplexLoopConditionsRule().diagnosticCode.problemMessage,
        'Avoid complex loop conditions. Extract the condition to a variable or method.',
      );
    });

    test('does report a complex for loop condition', () async {
      final unit = await resolveSource('''
void f() {
  for (int i = 0; i < 10 && i % 2 == 0; i++) {
    print(i);
  }
}
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidComplexLoopConditionsRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does report a complex for loop condition with multiple logical operators', () async {
      final unit = await resolveSource('''
void f() {
  for (int i = 0; i < 10 && (i % 2 == 0 || i % 3 == 0); i++) {
    print(i);
  }
}
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidComplexLoopConditionsRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report a simple for loop condition', () async {
      final unit = await resolveSource('''
void f() {
  for (int i = 0; i < 10; i++) {
    print(i);
  }
}
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidComplexLoopConditionsRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
