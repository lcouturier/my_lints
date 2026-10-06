import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/async/prefer_return_await_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferReturnAwaitRule', () {
    test('reports returning a future from a try-catch in a function', () async {
      final unit = await resolveSource('''
Future<void> save() async {}

Future<void> saveWithHandling() async {
  try {
    return save();
  } catch (_) {}
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferReturnAwaitRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('reports returning a future from a try-catch in a method', () async {
      final unit = await resolveSource('''
Future<void> save() async {}

class Repository {
  Future<void> saveWithHandling() async {
    try {
      return save();
    } catch (_) {}
  }
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferReturnAwaitRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report returning an awaited future', () async {
      final unit = await resolveSource('''
Future<void> save() async {}

Future<void> saveWithHandling() async {
  try {
    return await save();
  } catch (_) {}
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferReturnAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report returning a future without a catch clause', () async {
      final unit = await resolveSource('''
Future<void> save() async {}

Future<void> saveWithoutHandling() async {
  try {
    return save();
  } finally {}
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferReturnAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report returning a non-future value', () async {
      final unit = await resolveSource('''
Future<int> load() async {
  try {
    return 1;
  } catch (_) {}
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferReturnAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
