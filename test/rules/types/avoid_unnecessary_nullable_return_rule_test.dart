import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/avoid_unnecessary_nullable_return_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidUnnecessaryNullableReturnRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidUnnecessaryNullableReturnRule().diagnosticCode.name,
          'avoid_unnecessary_nullable_return');
    });

    test('registers the function declaration nodes inspected by the rule', () {
      expect(
        registeredNodeTypes(AvoidUnnecessaryNullableReturnRule()),
        containsAll(['FunctionDeclaration', 'MethodDeclaration']),
      );
    });

    test('reports a function with nullable return that never returns null',
        () async {
      final unit = await resolveSource('''
String? getName() {
  return 'John';
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          hasLength(1));
    });

    test('reports a method with nullable return that never returns null',
        () async {
      final unit = await resolveSource('''
class Person {
  String? getName() {
    return 'John';
  }
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          hasLength(1));
    });

    test('does not report a function with nullable return that returns null',
        () async {
      final unit = await resolveSource('''
String? getName(bool shouldBeNull) {
  if (shouldBeNull) {
    return null;
  }
  return 'John';
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          isEmpty);
    });

    test('does not report a function with explicit return null', () async {
      final unit = await resolveSource('''
String? getName() {
  return null;
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          isEmpty);
    });

    test('does not report a function with bare return statement', () async {
      final unit = await resolveSource('''
String? getName() {
  return;
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          isEmpty);
    });

    test('does not report a function with non-nullable return type', () async {
      final unit = await resolveSource('''
String getName() {
  return 'John';
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          isEmpty);
    });

    test('does not report an abstract method', () async {
      final unit = await resolveSource('''
abstract class Person {
  String? getName();
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          isEmpty);
    });

    test('does not report a method that overrides another method', () async {
      final unit = await resolveSource('''
abstract class Person {
  String? getName();
}

class Employee extends Person {
  @override
  String? getName() {
    return 'John';
  }
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          isEmpty);
    });

    test('does not report a copyWith method', () async {
      final unit = await resolveSource('''
class Person {
  final String name;
  Person({required this.name});

  Person? copyWith({String? name}) {
    return Person(name: name ?? this.name);
  }
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          isEmpty);
    });

    test('does not report an external method', () async {
      final unit = await resolveSource('''
class Person {
  external String? getName();
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          isEmpty);
    });

    test('does not report a function with inferred return type', () async {
      final unit = await resolveSource('''
getName() {
  return 'John';
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          isEmpty);
    });

    test(
        'reports a function with multiple return statements that never return null',
        () async {
      final unit = await resolveSource('''
String? getName(bool isLong) {
  if (isLong) {
    return 'John Doe';
  }
  return 'John';
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          hasLength(1));
    });

    test('does not report a function with conditional null return', () async {
      final unit = await resolveSource('''
String? getName(bool shouldBeNull) {
  return shouldBeNull ? null : 'John';
}
''');
      // Does not report because ternary can return null
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          isEmpty);
    });

    test('reports a getter with nullable return that never returns null',
        () async {
      final unit = await resolveSource('''
class Person {
  String? get name => 'John';
}
''');
      expect(runAnalysisRuleOnUnit(AvoidUnnecessaryNullableReturnRule(), unit),
          hasLength(1));
    });
  });
}
