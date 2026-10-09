import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/classes/equatable_props_must_include_all_fields_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('EquatablePropsMustIncludeAllFieldsRule', () {
    test('exposes the expected diagnostic code', () {
      final rule = EquatablePropsMustIncludeAllFieldsRule();

      expect(rule.diagnosticCode.name, 'equatable_props_must_include_all_fields');
      expect(rule.diagnosticCode.problemMessage, 'props getter is missing fields: {0}');
      expect(rule.diagnosticCode.correctionMessage, 'Add missing fields {0} to props');
    });

    test('reports when props is missing fields', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});

  @override
  List<Object?> get props => [name];
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), hasLength(1));
    });

    test('does not report when props includes all fields', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});

  @override
  List<Object?> get props => [name, age];
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), isEmpty);
    });

    test('reports when props getter is missing', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), hasLength(1));
    });

    test('does not report non-Equatable classes', () async {
      final unit = await resolveSource('''
class Person {
  final String name;
  final int age;
  Person({required this.name, required this.age});
}
''');

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), isEmpty);
    });

    test('does not report Equatable classes with no fields', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class EmptyState extends Equatable {
  @override
  List<Object?> get props => [];
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), isEmpty);
    });

    test('reports multiple missing fields', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  final String email;
  Person({required this.name, required this.age, required this.email});

  @override
  List<Object?> get props => [name];
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), hasLength(1));
    });

    test('handles props with complex expressions', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});

  @override
  List<Object?> get props => [name, age];
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), isEmpty);
    });
  });
}
