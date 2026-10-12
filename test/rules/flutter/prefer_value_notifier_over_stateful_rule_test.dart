import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/prefer_value_notifier_over_stateful_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferValueNotifierOverStatefulRule', () {
    test('reports a simple StatefulWidget with one mutable field', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() => _count++),
      child: Text('\$_count'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferValueNotifierOverStatefulRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report a StatelessWidget', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text('Hello');
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferValueNotifierOverStatefulRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report a StatefulWidget with multiple mutable fields', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class ComplexWidget extends StatefulWidget {
  @override
  State<ComplexWidget> createState() => _ComplexWidgetState();
}

class _ComplexWidgetState extends State<ComplexWidget> {
  int _count = 0;
  String _name = '';

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() {
        _count++;
        _name = 'test';
      }),
      child: Text('\$_count \$_name'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferValueNotifierOverStatefulRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report a StatefulWidget with no mutable fields', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class SimpleWidget extends StatefulWidget {
  @override
  State<SimpleWidget> createState() => _SimpleWidgetState();
}

class _SimpleWidgetState extends State<SimpleWidget> {
  @override
  Widget build(BuildContext context) {
    return const Text('Hello');
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferValueNotifierOverStatefulRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report a StatefulWidget with initState', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _count = 10;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() => _count++),
      child: Text('\$_count'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferValueNotifierOverStatefulRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report a StatefulWidget with dispose', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() => _count++),
      child: Text('\$_count'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferValueNotifierOverStatefulRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports a StatefulWidget with multiple setState calls', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _count++),
          child: Text('\$_count'),
        ),
        ElevatedButton(
          onPressed: () => setState(() => _count--),
          child: Text('\$_count'),
        ),
      ],
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferValueNotifierOverStatefulRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report a non-Flutter class', () async {
      final unit = await resolveSource('''
class NotAWidget {}

class NotAState extends NotAWidget {
  int _count = 0;
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferValueNotifierOverStatefulRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
