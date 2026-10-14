import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/prefer_on_prefix_for_widget_callbacks_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferOnPrefixForWidgetCallbacksRule', () {
    test('reports public callback fields without the on prefix', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

typedef SaveCallback = Future<void> Function(String value);

class SaveButton extends StatelessWidget {
  final SaveCallback save;
  final VoidCallback onCancel;
  final String label;

  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferOnPrefixForWidgetCallbacksRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('ignores private fields and callbacks outside Flutter widgets', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback _save;

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class SaveController {
  final VoidCallback save;
  SaveController(this.save);
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferOnPrefixForWidgetCallbacksRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports callback fields declared by StatefulWidget', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class SaveButton extends StatefulWidget {
  const SaveButton({required this.save, super.key});

  final VoidCallback save;

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferOnPrefixForWidgetCallbacksRule(), unit);

      expect(diagnostics, hasLength(1));
    });
  });
}
