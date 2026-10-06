import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/async/avoid_useless_async_method_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidUselessAsyncMethodRule', () {
    test('reports async method without await', () async {
      final unit = await resolveSource('''
Future<void> foo() async {
  print('Hello');
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report async method with await', () async {
      final unit = await resolveSource('''
Future<void> foo() async {
  await Future.delayed(Duration(seconds: 1));
  print('Hello');
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report private async method without await', () async {
      final unit = await resolveSource('''
Future<void> _foo() async {
  print('Hello');
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report non-async method', () async {
      final unit = await resolveSource('''
Future<void> foo() {
  print('Hello');
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report static async method without await', () async {
      final unit = await resolveSource('''
Future<void> foo() async {
  print('Hello');
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report getter with async', () async {
      final unit = await resolveSource('''
Future<void> get foo async {
  print('Hello');
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report setter with async', () async {
      final unit = await resolveSource('''
set foo(Future<void> value) async {
  print('Hello');
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports async function declaration without await', () async {
      final unit = await resolveSource('''
Future<void> foo() async {
  print('Hello');
}

void main() {
  foo();
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report async function declaration with await', () async {
      final unit = await resolveSource('''
Future<void> foo() async {
  await Future.delayed(Duration(seconds: 1));
  print('Hello');
}

void main() {
  foo();
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report private async function declaration without await', () async {
      final unit = await resolveSource('''
Future<void> _foo() async {
  print('Hello');
}

void main() {
  _foo();
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
