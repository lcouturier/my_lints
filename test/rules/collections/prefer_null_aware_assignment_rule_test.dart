import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/fixes/prefer_null_aware_assignment_fix.dart';
import 'package:my_lints/src/rules/collections/prefer_null_aware_assignment_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferNullAwareAssignmentRule', () {
    test('exposes the expected diagnostic code', () {
      final rule = PreferNullAwareAssignmentRule();

      expect(rule.diagnosticCode.name, 'prefer_null_aware_assignment');
      expect(rule.diagnosticCode.correctionMessage, 'Use ??= instead of explicit null check and assignment.');
    });

    test('reports a replaceable null check followed by assignment', () {
      final diagnostics = runAnalysisRule(PreferNullAwareAssignmentRule(), '''
void f(int? a) {
  if (a == null) {
    a = 42;
  }
}
''');

      expect(diagnostics, hasLength(1));
    });

    test('does not report a null check with additional assignments', () {
      final diagnostics = runAnalysisRule(PreferNullAwareAssignmentRule(), '''
void f(int? a) {
  int b = 0;
  if (a == null) {
    b = 10;
    a = 42;
  }
}
''');

      expect(diagnostics, isEmpty);
    });

    test('does not report a null check that contains an else branch', () {
      final diagnostics = runAnalysisRule(PreferNullAwareAssignmentRule(), '''
void f(int? a) {
  if (a == null) {
    a = 42;
  } else {
    a = 10;
  }
}
''');

      expect(diagnostics, isEmpty);
    });

    test('does not report a null check that assigns a different variable', () {
      final diagnostics = runAnalysisRule(PreferNullAwareAssignmentRule(), '''
void f(int? a, int? b) {
  if (a == null) {
    b = 42;
  }
}
''');

      expect(diagnostics, isEmpty);
    });

    test('fix replaces the if statement with a null-aware assignment', () async {
      const source = '''
void f(int? a) {
  if (a == null) {
    a = 42;
  }
}
''';

      final result = await applyResolvedFix(
        source,
        PreferNullAwareAssignmentFix.new,
        selectionOffset: source.indexOf('if ('),
      );

      expect(result, '''
void f(int? a) {
  a ??= 42;
}
''');
    });

    test('in-file fix replaces only valid occurrences', () async {
      const source = '''
void f(int? a, int? b) {
  if (a == null) {
    a = 42;
  }
  if (b == null) {
    b = 7;
  } else {
    b = 8;
  }
}
''';

      final result = await applyResolvedFix(
        source,
        PreferNullAwareAssignmentFixInFile.new,
        selectionOffset: source.indexOf('if ('),
      );

      expect(result, '''
void f(int? a, int? b) {
  a ??= 42;
  if (b == null) {
    b = 7;
  } else {
    b = 8;
  }
}
''');
    });
  });
}
