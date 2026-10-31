import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/fixes/prefer_if_case_over_is_fix.dart';
import 'package:my_lints/src/rules/types/prefer_if_case_over_is_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferIfCaseOverIsRule', () {
    test('registers an if statement processor', () {
      expect(registeredNodeTypes(PreferIfCaseOverIsRule()), {'IfStatement'});
    });

    test('reports a type check followed by property access on the value', () {
      expect(
        runAnalysisRule(
          PreferIfCaseOverIsRule(),
          'void f(Object state) { if (state is ErrorState) { print(state.error); } }',
        ),
        hasLength(1),
      );
    });

    test('does not report a type check without property access', () {
      expect(
        runAnalysisRule(
          PreferIfCaseOverIsRule(),
          'void f(Object state) { if (state is ErrorState) { print(state); } }',
        ),
        isEmpty,
      );
    });

    test('does not report a negated type check', () {
      expect(
        runAnalysisRule(
          PreferIfCaseOverIsRule(),
          'void f(Object state) { if (state is! ErrorState) { print(state.error); } }',
        ),
        isEmpty,
      );
    });

    test('does not report property access on a different value', () {
      expect(
        runAnalysisRule(
          PreferIfCaseOverIsRule(),
          'void f(Object state, Object other) { if (state is ErrorState) { print(other.error); } }',
        ),
        isEmpty,
      );
    });
  });

  group('PreferIfCaseOverIsFix', () {
    test('converts a single property access to an if-case pattern', () async {
      const source = '''
void f(Object state) {
  if (state is ErrorState) {
    print(state.error);
  }
}
''';
      const expected = '''
void f(Object state) {
  if (state case ErrorState(:final error)) {
    print(error);
  }
}
''';
      final result = await applyResolvedFix(
        source,
        PreferIfCaseOverIsFix.new,
        selectionOffset: source.indexOf('state is ErrorState'),
      );
      expect(result, expected);
    });

    test('destructures multiple distinct properties', () async {
      const source = '''
void f(Object state) {
  if (state is ErrorState) {
    print(state.error);
    log(state.message);
  }
}
''';
      const expected = '''
void f(Object state) {
  if (state case ErrorState(:final error, :final message)) {
    print(error);
    log(message);
  }
}
''';
      final result = await applyResolvedFix(
        source,
        PreferIfCaseOverIsFix.new,
        selectionOffset: source.indexOf('state is ErrorState'),
      );
      expect(result, expected);
    });

    test('deduplicates repeated accesses to the same property', () async {
      const source = '''
void f(Object state) {
  if (state is ErrorState) {
    print(state.error);
    log(state.error);
  }
}
''';
      const expected = '''
void f(Object state) {
  if (state case ErrorState(:final error)) {
    print(error);
    log(error);
  }
}
''';
      final result = await applyResolvedFix(
        source,
        PreferIfCaseOverIsFix.new,
        selectionOffset: source.indexOf('state is ErrorState'),
      );
      expect(result, expected);
    });

    test('does not produce a fix when the IsExpression is negated', () async {
      const source = '''
void f(Object state) {
  if (state is! ErrorState) {
    print(state.error);
  }
}
''';
      final result = await applyResolvedFix(
        source,
        PreferIfCaseOverIsFix.new,
        selectionOffset: source.indexOf('state is! ErrorState'),
      );
      // No edits applied — source unchanged.
      expect(result, source);
    });
  });
}
