import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/edge_insets_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('EdgeInsetsRule', () {
    test('reports symmetric values passed to EdgeInsets.only', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  EdgeInsets padding() => const EdgeInsets.only(left: 8, right: 8);
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EdgeInsetsRule(), unit), hasLength(1));
    });

    test('does not report asymmetric values', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  EdgeInsets padding() => const EdgeInsets.only(left: 8, right: 4);
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EdgeInsetsRule(), unit), isEmpty);
    });

    test('reports EdgeInsets.only nested in another constructor', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(left: 8, right: 8),
    child: const SizedBox(),
  );
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EdgeInsetsRule(), unit), hasLength(1));
    });

    test('reports symmetric double values passed to EdgeInsets.fromLTRB', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  EdgeInsets padding() => const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0);
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EdgeInsetsRule(), unit), hasLength(1));
    });

    test('does not report an unrelated class named EdgeInsets', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart' as flutter;

class EdgeInsets {
  const EdgeInsets.only({required this.left, required this.right});
  final double left;
  final double right;
}

class ExampleWidget extends flutter.StatefulWidget {
  const ExampleWidget({super.key});
  @override
  flutter.State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends flutter.State<ExampleWidget> {
  EdgeInsets padding() => const EdgeInsets.only(left: 8, right: 8);
  @override
  flutter.Widget build(flutter.BuildContext context) => const flutter.SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EdgeInsetsRule(), unit), isEmpty);
    });
  });
}
