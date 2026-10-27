import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/classes/proper_super_calls_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('ProperSuperCallsRule', () {
    test('reports missing or incorrectly ordered lifecycle super calls', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => ExampleWidgetState();
}

class ExampleWidgetState extends State<ExampleWidget> {
  @override
  void initState() {
    performSetup();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    performCleanup();
  }

  void performSetup() {}
  void performCleanup() {}
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(ProperSuperCallsRule(), unit), hasLength(2));
    });

    test('does not report correctly ordered lifecycle super calls', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => ExampleWidgetState();
}

class ExampleWidgetState extends State<ExampleWidget> {
  @override
  void initState() {
    super.initState();
    performSetup();
  }

  @override
  void dispose() {
    performCleanup();
    super.dispose();
  }

  void performSetup() {}
  void performCleanup() {}
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(ProperSuperCallsRule(), unit), isEmpty);
    });

    test('reports when super.initState() is not the first statement', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => ExampleWidgetState();
}

class ExampleWidgetState extends State<ExampleWidget> {
  @override
  void initState() {
    performSetup();
    super.initState();
  }

  void performSetup() {}
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(ProperSuperCallsRule(), unit), hasLength(1));
    });

    test('reports when super.dispose() is not the last statement', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => ExampleWidgetState();
}

class ExampleWidgetState extends State<ExampleWidget> {
  @override
  void dispose() {
    super.dispose();
    performCleanup();
  }

  void performCleanup() {}
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(ProperSuperCallsRule(), unit), hasLength(1));
    });

    test('does not report for classes that are not StatefulWidget states', () async {
      final unit = await resolveSource('''
class NotAState {
  void initState() {
    print('no super call needed');
  }

  void dispose() {
    print('no super call needed');
  }
}
''');

      expect(runAnalysisRuleOnUnit(ProperSuperCallsRule(), unit), isEmpty);
    });

    test('does not report when super calls are in correct order with multiple statements', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => ExampleWidgetState();
}

class ExampleWidgetState extends State<ExampleWidget> {
  @override
  void initState() {
    super.initState();
    performSetup();
    initializeController();
  }

  @override
  void dispose() {
    cleanupController();
    performCleanup();
    super.dispose();
  }

  void performSetup() {}
  void initializeController() {}
  void cleanupController() {}
  void performCleanup() {}
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(ProperSuperCallsRule(), unit), isEmpty);
    });
  });
}
