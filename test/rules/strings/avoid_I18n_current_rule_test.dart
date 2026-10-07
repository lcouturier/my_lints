import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/strings/avoid_I18n_current_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidI18nCurrentRule', () {
    test('reports I18n.current in a function with BuildContext', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';
class I18n { static final I18n current = I18n(); }
String title(BuildContext context) => I18n.current.toString();
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidI18nCurrentRule(), unit), hasLength(1));
    });

    test('does not report I18n.current without a BuildContext parameter', () async {
      final unit = await resolveSource('''
class I18n { static final I18n current = I18n(); }
String title() => I18n.current.toString();
''');

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
  });
}
