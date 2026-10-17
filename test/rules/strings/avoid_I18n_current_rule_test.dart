import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/fixes/avoid_i18n_current_fix.dart';
import 'package:my_lints/src/rules/strings/avoid_I18n_current_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidI18nCurrentRule', () {
    test('reports I18n.current in a function with BuildContext', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';
class I18n { static final I18n current = I18n(); static I18n of(BuildContext context) => I18n(); }
String title(BuildContext context) => I18n.current.toString();
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidI18nCurrentRule(), unit), hasLength(1));
    });

    test('reports I18n.current with a named BuildContext parameter', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';
class I18n { static final I18n current = I18n(); static I18n of(BuildContext context) => I18n(); }
String title({required BuildContext context}) => I18n.current.toString();
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidI18nCurrentRule(), unit), hasLength(1));
    });

    test('does not inherit BuildContext in a local function', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';
class I18n { static final I18n current = I18n(); static I18n of(BuildContext context) => I18n(); }
String title(BuildContext context) {
  String localTitle() => I18n.current.toString();
  return localTitle();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidI18nCurrentRule(), unit), isEmpty);
    });

    test('does not report I18n.current without a BuildContext parameter', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';
class I18n { static final I18n current = I18n(); static I18n of(BuildContext context) => I18n(); }
String title() => I18n.current.toString();
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidI18nCurrentRule(), unit), isEmpty);
    });

    test('does not report I18n.current in a function with BuildContext but using I18n.of(context)', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';
class I18n { static final I18n current = I18n(); static I18n of(BuildContext context) => I18n(); }
String title(BuildContext context) => I18n.of(context).toString();
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidI18nCurrentRule(), unit), isEmpty);
    });

    test('fix preserves access after I18n.current', () async {
      const source = '''
import 'package:flutter/widgets.dart';
class I18n {
  static final I18n current = I18n();
  static I18n of(BuildContext context) => I18n();
  String get title => 'title';
}
String title(BuildContext context) => I18n.current.title;
''';

      final result = await applyResolvedFix(
        source,
        AvoidI18nCurrentFix.new,
        selectionOffset: source.indexOf('I18n.current'),
        selectionLength: 'I18n.current'.length,
        useExamplePackages: true,
      );

      expect(result, source.replaceFirst('I18n.current.title', 'I18n.of(context).title'));
    });

    test('does not report or fix when a closure shadows context', () async {
      const source = '''
import 'package:flutter/widgets.dart';
class I18n {
  static final I18n current = I18n();
  static I18n of(BuildContext context) => I18n();
}
Iterable<String> titles(BuildContext context) =>
    [1].map((context) => I18n.current.toString());
''';
      final unit = await resolveSource(source, useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidI18nCurrentRule(), unit), isEmpty);

      final result = await applyResolvedFix(
        source,
        AvoidI18nCurrentFix.new,
        selectionOffset: source.indexOf('I18n.current'),
        selectionLength: 'I18n.current'.length,
        useExamplePackages: true,
      );
      expect(result, source);
    });

    test('does not report or fix a local variable named I18n', () async {
      const source = '''
import 'package:flutter/widgets.dart';
class FakeI18n { final String current = 'current'; }
String title(BuildContext context) {
  final I18n = FakeI18n();
  return I18n.current;
}
''';
      final unit = await resolveSource(source, useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidI18nCurrentRule(), unit), isEmpty);

      final result = await applyResolvedFix(
        source,
        AvoidI18nCurrentFix.new,
        selectionOffset: source.indexOf('I18n.current'),
        selectionLength: 'I18n.current'.length,
        useExamplePackages: true,
      );
      expect(result, source);
    });

    test('in-file fix uses each function context', () async {
      const source = '''
import 'package:flutter/widgets.dart';
class I18n {
  static final I18n current = I18n();
  static I18n of(BuildContext context) => I18n();
}
String first(BuildContext firstContext) => I18n.current.toString();
String second(BuildContext secondContext) => I18n.current.toString();
''';

      final result = await applyResolvedFix(
        source,
        AvoidI18nCurrentFixInFile.new,
        selectionOffset: source.indexOf('I18n.current'),
        selectionLength: 'I18n.current'.length,
        useExamplePackages: true,
      );

      expect(
        result,
        source
            .replaceFirst('I18n.current', 'I18n.of(firstContext)')
            .replaceFirst('I18n.current', 'I18n.of(secondContext)'),
      );
    });

    test('in-file fix respects context shadowing in closures', () async {
      const source = '''
import 'package:flutter/widgets.dart';
class I18n {
  static final I18n current = I18n();
  static I18n of(BuildContext context) => I18n();
}
Iterable<String> titles(BuildContext context) sync* {
  yield I18n.current.toString();
  yield* [1].map((value) => I18n.current.toString());
  yield* [1].map((context) => I18n.current.toString());
}
''';

      final result = await applyResolvedFix(
        source,
        AvoidI18nCurrentFixInFile.new,
        selectionOffset: source.indexOf('I18n.current'),
        selectionLength: 'I18n.current'.length,
        useExamplePackages: true,
      );

      expect(
        result,
        source.replaceFirst('I18n.current', 'I18n.of(context)').replaceFirst('I18n.current', 'I18n.of(context)'),
      );
    });
  });
}
