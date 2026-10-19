import 'package:flutter_test/flutter_test.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:my_lints/src/rules/flutter/avoid_set_state_after_await_without_mounted_check_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidSetStateAfterAwaitWithoutMountedCheckRule', () {
    test('exposes the expected diagnostic', () {
      final rule = AvoidSetStateAfterAwaitWithoutMountedCheckRule();

      expect(rule.diagnosticCode.name, 'avoid_set_state_after_await_without_mounted_check');
      expect(
        rule.diagnosticCode.correctionMessage,
        'Check mounted after the asynchronous operation before calling setState.',
      );
      expect(registeredNodeTypes(rule), {'ClassDeclaration'});
    });

    test('reports setState after await without a mounted check', () async {
      final diagnostics = await _runRule('''
  Future<void> load() async {
    final result = await Future.value(1);
    setState(() => value = result);
  }
''');

      expect(diagnostics, hasLength(1));
    });

    test('accepts an early mounted exit after await', () async {
      final diagnostics = await _runRule('''
  Future<void> load() async {
    final result = await Future.value(1);
    if (!mounted) return;
    setState(() => value = result);
  }
''');

      expect(diagnostics, isEmpty);
    });

    test('accepts setState guarded by mounted after await', () async {
      final diagnostics = await _runRule('''
  Future<void> load() async {
    final result = await Future.value(1);
    if (mounted) {
      setState(() => value = result);
    }
  }
''');

      expect(diagnostics, isEmpty);
    });

    test('reports when the mounted check occurs before the latest await', () async {
      final diagnostics = await _runRule('''
  Future<void> load() async {
    if (!mounted) return;
    final result = await Future.value(1);
    setState(() => value = result);
  }
''');

      expect(diagnostics, hasLength(1));
    });

    test('reports when another await follows the mounted check', () async {
      final diagnostics = await _runRule('''
  Future<void> load() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final result = await Future.value(1);
    setState(() => value = result);
  }
''');

      expect(diagnostics, hasLength(1));
    });

    test('does not report setState before the first await', () async {
      final diagnostics = await _runRule('''
  Future<void> load() async {
    setState(() => value = 1);
    await Future<void>.delayed(Duration.zero);
  }
''');

      expect(diagnostics, isEmpty);
    });

    test('accepts this.mounted after await', () async {
      final diagnostics = await _runRule('''
  Future<void> load() async {
    final result = await Future.value(1);
    if (!this.mounted) return;
    this.setState(() => value = result);
  }
''');

      expect(diagnostics, isEmpty);
    });

    test('does not treat awaits in nested callbacks as an asynchronous gap', () async {
      final diagnostics = await _runRule('''
  Future<void> load() async {
    [1].forEach((item) async {
      await Future<void>.delayed(Duration.zero);
    });
    setState(() => value = 1);
  }
''');

      expect(diagnostics, isEmpty);
    });

    test('does not report qualified setState calls', () async {
      final diagnostics = await _runRule('''
  Future<void> load(dynamic other) async {
    await Future<void>.delayed(Duration.zero);
    other.setState(() {});
  }
''');

      expect(diagnostics, isEmpty);
    });
  });
}

Future<List<AstNode>> _runRule(String method) async {
  final unit = await resolveSource('''
import 'package:flutter/material.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => TestState();
}

class TestState extends State<TestWidget> {
  int value = 0;

$method

  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useWorkspacePackages: true);

  return runAnalysisRuleOnUnit(AvoidSetStateAfterAwaitWithoutMountedCheckRule(), unit);
}
